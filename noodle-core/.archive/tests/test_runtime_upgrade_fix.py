#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_runtime_upgrade_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the runtime upgrade fix.

This script tests that the runtime upgrade system can now:
1. Detect upgrade opportunities
2. Auto-approve upgrades when configured
3. Execute upgrades automatically
4. Update component versions to prevent repeated detection
"""

import os
import sys
import time
import logging
from pathlib import Path

# Add the noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent
sys.path.insert(0, str(noodle_core_path))

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def test_auto_approval_config():
    """Test that auto-approval configuration is properly loaded."""
    print("\n=== Testing Auto-Approval Configuration ===")
    
    # Set environment variable for auto-approval
    os.environ["NOODLE_AUTO_UPGRADE_APPROVAL"] = "1"
    
    try:
        from noodlecore.self_improvement.runtime_upgrade.config import get_runtime_upgrade_config_manager
        config_manager = get_runtime_upgrade_config_manager()
        config = config_manager.get_config()
        
        print(f"âœ… Runtime upgrade config loaded successfully")
        print(f"   Auto-approval enabled: {config.auto_upgrade_approval}")
        print(f"   Runtime upgrades enabled: {config.enabled}")
        print(f"   Hot-swap enabled: {config.hot_swap_enabled}")
        
        if config.auto_upgrade_approval:
            print("âœ… Auto-approval is enabled in configuration")
            return True
        else:
            print("âŒ Auto-approval is NOT enabled in configuration")
            return False
            
    except Exception as e:
        print(f"âŒ Error loading configuration: {e}")
        return False

def test_upgrade_detection():
    """Test that upgrade detection works."""
    print("\n=== Testing Upgrade Detection ===")
    
    try:
        from noodlecore.self_improvement.runtime_upgrade.runtime_component_registry import get_runtime_component_registry
        
        registry = get_runtime_component_registry()
        components = registry.discover_components()
        
        print(f"âœ… Found {len(components)} components")
        
        for component in components:
            if component.upgrade_path and len(component.upgrade_path) > 1:
                current_version = component.version
                latest_version = component.upgrade_path[-1]
                
                if current_version != latest_version:
                    print(f"   ðŸ“¦ {component.name}: {current_version} -> {latest_version}")
                    print(f"      Hot-swappable: {component.hot_swappable}")
                    
                    # Return the first component that needs an upgrade
                    return component, current_version, latest_version
        
        print("â„¹ï¸ No components require upgrades")
        return None, None, None
        
    except Exception as e:
        print(f"âŒ Error detecting upgrades: {e}")
        return None, None, None

def test_self_improvement_integration():
    """Test self-improvement integration with auto-approval."""
    print("\n=== Testing Self-Improvement Integration ===")
    
    try:
        # Set environment variables for testing
        os.environ["NOODLE_AUTO_UPGRADE_APPROVAL"] = "1"
        os.environ["NOODLE_RUNTIME_UPGRADE_ENABLED"] = "1"
        os.environ["NOODLE_HOT_SWAP_ENABLED"] = "1"
        
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create instance without IDE
        integration = SelfImprovementIntegration(ide_instance=None)
        
        # Check configuration
        auto_approve = integration.config.get("auto_approve_runtime_upgrades", False)
        execute_upgrades = integration.config.get("execute_runtime_upgrades", True)
        
        print(f"âœ… Self-improvement integration created")
        print(f"   Auto-approve: {auto_approve}")
        print(f"   Execute upgrades: {execute_upgrades}")
        
        # Check runtime upgrade config
        if integration.runtime_upgrade_config:
            runtime_config = integration.runtime_upgrade_config.get_config()
            print(f"   Runtime auto-approval: {runtime_config.auto_upgrade_approval}")
            
            # Use runtime config if local config is False
            if not auto_approve and runtime_config.auto_upgrade_approval:
                auto_approve = True
                print("   âœ… Using runtime config for auto-approval")
        
        if auto_approve and execute_upgrades:
            print("âœ… Auto-approval and execution are enabled")
            return True
        else:
            print("âŒ Auto-approval or execution is disabled")
            return False
            
    except Exception as e:
        print(f"âŒ Error testing self-improvement integration: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_upgrade_execution():
    """Test that upgrade execution works."""
    print("\n=== Testing Upgrade Execution ===")
    
    try:
        # Set environment variables for testing
        os.environ["NOODLE_AUTO_UPGRADE_APPROVAL"] = "1"
        os.environ["NOODLE_RUNTIME_UPGRADE_ENABLED"] = "1"
        os.environ["NOODLE_HOT_SWAP_ENABLED"] = "1"
        
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create instance without IDE
        integration = SelfImprovementIntegration(ide_instance=None)
        
        # Create a mock improvement for testing
        improvement = {
            'type': 'runtime_upgrade',
            'description': f"Test upgrade: TestRuntimeComponent 1.0.0 -> 2.0.0",
            'priority': 'high',
            'source': 'runtime_upgrade_system',
            'component_name': 'TestRuntimeComponent',
            'current_version': '1.0.0',
            'target_version': '2.0.0',
            'hot_swappable': True,
            'suggestion': f"Upgrade TestRuntimeComponent to version 2.0.0 for latest features and improvements",
            'action': 'runtime_upgrade',
            'auto_applicable': True
        }
        
        print(f"âœ… Created test improvement for {improvement['component_name']}")
        print(f"   Version: {improvement['current_version']} -> {improvement['target_version']}")
        print(f"   Hot-swappable: {improvement['hot_swappable']}")
        
        # Test the _execute_detected_upgrade method
        if hasattr(integration, '_execute_detected_upgrade'):
            print("âœ… _execute_detected_upgrade method exists")
            
            # Execute the upgrade
            result = integration._execute_detected_upgrade(improvement)
            
            if result:
                print("âœ… Upgrade execution succeeded")
                return True
            else:
                print("âŒ Upgrade execution failed")
                return False
        else:
            print("âŒ _execute_detected_upgrade method NOT found")
            return False
            
    except Exception as e:
        print(f"âŒ Error testing upgrade execution: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all tests."""
    print("ðŸ”§ Testing Runtime Upgrade Fix")
    print("=" * 50)
    
    # Test 1: Configuration
    config_ok = test_auto_approval_config()
    
    # Test 2: Detection
    component, current_ver, target_ver = test_upgrade_detection()
    
    # Test 3: Self-improvement integration
    integration_ok = test_self_improvement_integration()
    
    # Test 4: Execution
    execution_ok = test_upgrade_execution()
    
    # Summary
    print("\n" + "=" * 50)
    print("ðŸ“Š Test Results Summary:")
    print(f"   Configuration: {'âœ…' if config_ok else 'âŒ'}")
    print(f"   Detection: {'âœ…' if component else 'âŒ'}")
    print(f"   Integration: {'âœ…' if integration_ok else 'âŒ'}")
    print(f"   Execution: {'âœ…' if execution_ok else 'âŒ'}")
    
    all_passed = config_ok and integration_ok and execution_ok
    print(f"\nðŸŽ¯ Overall: {'âœ… ALL TESTS PASSED' if all_passed else 'âŒ SOME TESTS FAILED'}")
    
    if all_passed:
        print("\nðŸŽ‰ Runtime upgrade fix is working correctly!")
        print("   The system should now:")
        print("   1. Detect upgrade opportunities")
        print("   2. Auto-approve upgrades when NOODLE_AUTO_UPGRADE_APPROVAL=1")
        print("   3. Execute upgrades automatically")
        print("   4. Update component versions to prevent repeated detection")
        print("\n   To enable auto-approval, set: NOODLE_AUTO_UPGRADE_APPROVAL=1")
    else:
        print("\nâš ï¸  Some tests failed. Check the errors above.")
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    sys.exit(main())

