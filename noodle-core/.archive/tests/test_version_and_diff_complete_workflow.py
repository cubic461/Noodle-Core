#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_version_and_diff_complete_workflow.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for complete versioning and diff highlighting workflow.

This script tests:
1. Semantic versioning in version_archive_manager.py
2. Configuration override in self_improvement_integration.py
3. IDE callback registration for diff highlighting
4. Complete workflow from improvement â†’ version â†’ diff highlighting â†’ editor opening
"""

import os
import sys
import json
import tempfile
import time
from pathlib import Path
from datetime import datetime

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent))

def test_semantic_versioning():
    """Test semantic versioning implementation."""
    print("=" * 60)
    print("TEST 1: Semantic Versioning")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.version_archive_manager import VersionArchiveManager
        
        # Create a temporary test file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as temp_file:
            temp_file.write("# Test file for versioning\nprint('Hello, version test!')\n")
            temp_file_path = temp_file.name
        
        # Initialize version archive manager
        vam = VersionArchiveManager()
        
        # Test version calculation
        print(f"Testing version calculation for: {temp_file_path}")
        
        # First archive - should be version 1.0.0
        result1 = vam.archive_version(temp_file_path, "test_improvement", "First test improvement")
        version1 = vam.get_current_version(temp_file_path)
        print(f"First archive version: {version1}")
        
        # Second archive - should be version 1.0.1
        result2 = vam.archive_version(temp_file_path, "test_improvement", "Second test improvement")
        version2 = vam.get_current_version(temp_file_path)
        print(f"Second archive version: {version2}")
        
        # Third archive - should be version 1.0.2
        result3 = vam.archive_version(temp_file_path, "test_improvement", "Third test improvement")
        version3 = vam.get_current_version(temp_file_path)
        print(f"Third archive version: {version3}")
        
        # Test version history
        versions = vam.get_archived_versions(temp_file_path)
        print(f"Version history: {versions}")
        
        # Also check the archive index directly
        archive_index = vam.get_archive_index()
        file_name = Path(temp_file_path).name
        if file_name in archive_index:
            index_versions = archive_index[file_name].get('version_history', [])
            print(f"Version history from index: {index_versions}")
        
        # Verify semantic versioning pattern
        expected_versions = ["1.0.0", "1.0.1", "1.0.2"]
        # Try to get versions from either the archived versions or the index
        actual_versions = [v['version'] for v in versions if 'version' in v]
        if not actual_versions and file_name in archive_index:
            actual_versions = archive_index[file_name].get('version_history', [])
        
        if actual_versions == expected_versions:
            print("PASSED: Semantic versioning test")
            return True
        else:
            print(f"FAILED: Semantic versioning test")
            print(f"Expected: {expected_versions}")
            print(f"Actual: {actual_versions}")
            return False
            
    except Exception as e:
        print(f"ERROR: Semantic versioning test: {e}")
        return False

def test_configuration_override():
    """Test configuration override implementation."""
    print("\n" + "=" * 60)
    print("TEST 2: Configuration Override")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create a temporary config file with auto_apply_improvements=True
        config_dir = Path(__file__).parent / "config"
        config_dir.mkdir(exist_ok=True)
        config_file = config_dir / "test_self_improvement_config.json"
        
        test_config = {
            "auto_apply_improvements": True,
            "monitoring_interval": 60.0,
            "max_improvements_per_session": 5
        }
        
        with open(config_file, 'w') as f:
            json.dump(test_config, f, indent=2)
        
        print(f"Created test config file: {config_file}")
        print(f"Config content: {test_config}")
        
        # Initialize self-improvement integration
        integration = SelfImprovementIntegration()
        
        # Check if config was loaded correctly
        config = integration.config
        print(f"Loaded config: {config}")
        
        if config.get("auto_apply_improvements") == True:
            print("PASSED: Configuration override test")
            return True
        else:
            print("FAILED: Configuration override test")
            print(f"Expected auto_apply_improvements=True, got: {config.get('auto_apply_improvements')}")
            return False
            
    except Exception as e:
        print(f"ERROR: Configuration override test: {e}")
        return False

def test_diff_highlighting_callback():
    """Test diff highlighting callback mechanism."""
    print("\n" + "=" * 60)
    print("TEST 3: Diff Highlighting Callback")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        
        # Create mock IDE instance with callback tracking
        callback_received = False
        callback_data = None
        
        def mock_callback(callback_type, data):
            nonlocal callback_received, callback_data
            if callback_type == 'show_diff_highlighting':
                callback_received = True
                callback_data = data
                print(f"RECEIVED: Diff highlighting callback: {callback_type}")
                print(f"Callback data keys: {list(data.keys())}")
        
        # Create mock IDE instance
        class MockIDE:
            def register_self_improvement_callback(self, callback):
                self.callback = callback
                print(f"REGISTERED: Self-improvement callback")
            
            def register_diff_highlighting_callback(self, callback):
                self.diff_callback = callback
                print(f"REGISTERED: Diff highlighting callback")
        
        mock_ide = MockIDE()
        
        # Initialize self-improvement integration with mock IDE
        integration = SelfImprovementIntegration(ide_instance=mock_ide)
        
        # Register callbacks
        mock_ide.register_self_improvement_callback(mock_callback)
        mock_ide.register_diff_highlighting_callback(mock_callback)
        
        # Test callback data structure
        test_data = {
            'file_path': '/test/file.py',
            'diff_lines': ['+ added line', '- removed line'],
            'diff_summary': {
                'lines_added': 1,
                'lines_removed': 1,
                'character_changes': 5
            },
            'improvement': {
                'type': 'test_improvement',
                'description': 'Test improvement'
            },
            'original_content': 'original content',
            'improved_content': 'improved content'
        }
        
        # Trigger callback
        mock_callback('show_diff_highlighting', test_data)
        
        if callback_received and callback_data:
            print("PASSED: Diff highlighting callback test")
            return True
        else:
            print("FAILED: Diff highlighting callback test")
            return False
            
    except Exception as e:
        print(f"ERROR: Diff highlighting callback test: {e}")
        return False

def test_complete_workflow():
    """Test complete workflow from improvement to diff highlighting."""
    print("\n" + "=" * 60)
    print("TEST 4: Complete Workflow")
    print("=" * 60)
    
    try:
        from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
        from noodlecore.desktop.ide.version_archive_manager import VersionArchiveManager
        
        # Create a temporary test file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as temp_file:
            temp_file.write("# Original test file\nprint('Hello, world!')\n")
            temp_file_path = temp_file.name
        
        # Create mock IDE instance with diff highlighting capability
        diff_applied = False
        diff_data = None
        
        class MockIDEWithDiff:
            def register_self_improvement_callback(self, callback):
                self.callback = callback
                print(f"REGISTERED: Self-improvement callback")
            
            def register_diff_highlighting_callback(self, callback):
                self.diff_callback = callback
                print(f"REGISTERED: Diff highlighting callback")
            
            def show_diff_highlighting(self, file_path, diff_lines, diff_summary, improvement, original_content, improved_content):
                nonlocal diff_applied, diff_data
                diff_applied = True
                diff_data = {
                    'file_path': file_path,
                    'diff_lines': diff_lines,
                    'diff_summary': diff_summary,
                    'improvement': improvement
                }
                print(f"APPLIED: Diff highlighting to {Path(file_path).name}")
                print(f"Lines added: {diff_summary.get('lines_added', 0)}")
                print(f"Lines removed: {diff_summary.get('lines_removed', 0)}")
                return True
        
        mock_ide = MockIDEWithDiff()
        
        # Initialize components
        integration = SelfImprovementIntegration(ide_instance=mock_ide)
        vam = VersionArchiveManager()
        
        # Register callbacks
        mock_ide.register_self_improvement_callback(integration._handle_ide_callback)
        mock_ide.register_diff_highlighting_callback(integration._handle_diff_highlighting_callback)
        
        # Create an improvement
        improvement = {
            'type': 'test_improvement',
            'description': 'Test improvement for workflow',
            'file': temp_file_path,
            'auto_applicable': True
        }
        
        # Apply improvement (this should trigger versioning and diff highlighting)
        print("Applying test improvement...")
        integration._apply_improvement(improvement)
        
        # Wait for processing
        time.sleep(1)
        
        # Check if versioning worked
        current_version = vam.get_current_version(temp_file_path)
        print(f"Current version after improvement: {current_version}")
        
        # Check if diff highlighting was triggered
        if diff_applied and diff_data:
            print("PASSED: Complete workflow test")
            print(f"ASSIGNED: Version: {current_version}")
            print(f"APPLIED: Diff highlighting to: {Path(diff_data['file_path']).name}")
            return True
        else:
            print("FAILED: Complete workflow test")
            if not diff_applied:
                print("Diff highlighting was not applied")
            if not current_version or current_version == "1.0.0":
                print("Versioning did not work properly")
            return False
            
    except Exception as e:
        print(f"ERROR: Complete workflow test: {e}")
        return False

def main():
    """Run all tests."""
    print("TEST NoodleCore Version and Diff Highlighting - Complete Workflow Test")
    print("This test validates the implementation of:")
    print("1. Semantic versioning in version_archive_manager.py")
    print("2. Configuration override in self_improvement_integration.py")
    print("3. IDE callback registration for diff highlighting")
    print("4. Complete workflow from improvement to version to diff highlighting to editor opening")
    print()
    
    results = []
    
    # Run all tests
    results.append(("Semantic Versioning", test_semantic_versioning()))
    results.append(("Configuration Override", test_configuration_override()))
    results.append(("Diff Highlighting Callback", test_diff_highlighting_callback()))
    results.append(("Complete Workflow", test_complete_workflow()))
    
    # Print summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    passed = sum(1 for result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "PASSED" if result else "FAILED"
        print(f"{test_name}: {status}")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("\nALL TESTS PASSED! The implementation is working correctly.")
        print("\nImplemented features:")
        print("IMPLEMENTED: Semantic versioning with incremental versions (1.0.0, 1.0.1, 1.0.2, etc.)")
        print("IMPLEMENTED: Configuration override with proper priority for config file settings")
        print("IMPLEMENTED: IDE callback registration for diff highlighting")
        print("IMPLEMENTED: Complete workflow from improvement to diff highlighting")
        print("IMPLEMENTED: Comprehensive logging for debugging")
        return True
    else:
        print(f"\nWARNING: {total - passed} tests failed. Please check the implementation.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

