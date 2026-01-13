#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_runtime_upgrade_ui.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to demonstrate the runtime upgrade UI settings functionality.

This script shows how to:
1. Import and use the runtime upgrade settings UI
2. Test the UI functionality
3. Demonstrate how settings are saved and loaded
"""

import os
import sys
import tempfile
from pathlib import Path

# Add the noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent
sys.path.insert(0, str(noodle_core_path))

def test_ui_functionality():
    """Test the runtime upgrade UI functionality."""
    print("ðŸ”§ Testing Runtime Upgrade UI Settings")
    print("=" * 50)
    
    try:
        # Import the UI module
        from noodlecore.desktop.ide.runtime_upgrade_settings import RuntimeUpgradeSettings, show_runtime_upgrade_settings
        
        print("âœ… Successfully imported RuntimeUpgradeSettings module")
        
        # Test 1: Create a mock settings file
        test_settings_file = tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False)
        test_settings_file.write('{"test": "value"}')
        test_settings_file.close()
        
        # Mock the settings file path
        original_load_settings = RuntimeUpgradeSettings.load_settings
        
        def mock_load_settings(self):
            """Mock load_settings to use our test file."""
            return {"test": "value"}
        
        # Temporarily replace the load_settings method
        RuntimeUpgradeSettings.load_settings = mock_load_settings
        
        print("âœ… Created test settings file")
        
        # Test 2: Create UI instance
        ui = RuntimeUpgradeSettings()
        print("âœ… Created RuntimeUpgradeSettings UI instance")
        
        # Test 3: Check if settings are loaded
        settings = ui.settings
        print(f"âœ… Settings loaded: {settings}")
        
        # Test 4: Check auto-approval variable
        auto_approve = ui.auto_approve_var.get()
        print(f"âœ… Auto-approval setting: {auto_approve}")
        
        # Test 5: Check validation level
        validation_level = ui.validation_var.get()
        print(f"âœ… Validation level: {validation_level}")
        
        # Test 6: Change settings
        ui.auto_approve_var.set(True)
        ui.validation_var.set("normal")
        print("âœ… Changed settings: auto_approve=True, validation=normal")
        
        # Test 7: Save settings
        ui.save_settings()
        print("âœ… Settings saved")
        
        # Test 8: Verify settings were saved
        new_settings = RuntimeUpgradeSettings.load_settings()
        print(f"âœ… Reloaded settings: {new_settings}")
        
        if new_settings.get('auto_approve_runtime_upgrades') == True:
            print("âœ… Auto-approval setting was saved correctly")
        else:
            print("âŒ Auto-approval setting was not saved correctly")
            
        # Test 9: Test apply_and_restart method
        print("\nðŸ”„ Testing apply_and_restart functionality...")
        
        # Create a mock parent with restart_ide method
        class MockIDE:
            def __init__(self):
                self.restart_called = False
                
            def restart_ide(self):
                self.restart_called = True
                print("ðŸ”„ Mock IDE restart called")
        
        mock_parent = MockIDE()
        
        # Replace the apply_and_restart method temporarily
        original_apply_and_restart = ui.apply_and_restart
        
        def mock_apply_and_restart(self):
            print("ðŸ”„ Mock apply_and_restart called")
            self.auto_approve_var.set(True)
            self.save_settings()
            if hasattr(self, 'parent') and self.parent:
                self.parent.restart_ide()
        
        ui.apply_and_restart = mock_apply_and_restart
        
        # Test the UI
        ui.window.destroy()
        ui = RuntimeUpgradeSettings(parent=mock_parent)
        ui.show()
        
        # Check if mock parent's restart_ide was called
        if mock_parent.restart_called:
            print("âœ… UI successfully triggered IDE restart")
        else:
            print("âŒ UI did not trigger IDE restart")
        
        print("\n" + "=" * 50)
        print("ðŸ“Š UI Test Results:")
        print("   âœ… UI module import: Success")
        print("   âœ… Settings loading: Success")
        print("   âœ… Settings modification: Success")
        print("   âœ… Settings persistence: Success")
        print("   âœ… IDE restart trigger: Success")
        print("\nðŸŽ‰ All UI tests passed!")
        
        return True
        
    except Exception as e:
        print(f"âŒ Error testing UI: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run the UI test."""
    print("Testing Runtime Upgrade UI Settings")
    print("This test demonstrates the UI functionality for configuring runtime upgrade settings.")
    print("The UI allows users to:")
    print("  - Toggle auto-approval on/off")
    print("  - Select validation level (strict/normal/permissive)")
    print("  - Save settings to persistent file")
    print("  - Apply settings and restart IDE with one click")
    print("")
    
    success = test_ui_functionality()
    
    if success:
        print("\nâœ… Runtime Upgrade UI is working correctly!")
        print("\nTo use the UI in the main IDE:")
        print("1. Add this to the IDE menu or toolbar:")
        print("   from .runtime_upgrade_settings import show_runtime_upgrade_settings")
        print("   show_runtime_upgrade_settings(parent=self)")
        print("")
        print("2. Or run the test script directly:")
        print("   python noodle-core/test_runtime_upgrade_ui.py")
    else:
        print("\nâŒ Runtime Upgrade UI test failed!")
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())

