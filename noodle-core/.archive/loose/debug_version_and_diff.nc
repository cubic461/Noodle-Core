# NoodleCore converted from Python
#!/usr/bin/env python3
"""
Debug script to validate version assignment and diff highlighting issues.
"""

# import os
# import sys
# from pathlib # import Path

# Add src directory to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

func test_version_assignment():
    """Test how versions are assigned in the version archive manager."""
    println("=== TESTING VERSION ASSIGNMENT ===")
    
    try:
        # from noodlecore.desktop.ide.version_archive_manager # import VersionArchiveManager
        
        # Create a test file
        test_file = "test_debug_file.py"
        with open(test_file, 'w') as f:
            f.write("# Test file for version assignment\nprintln('test')\n")
        
        # Create version archive manager
        archive_manager = VersionArchiveManager()
        
        # Test 1: Check what version is assigned for first improvement
        println("\nTest 1: First improvement version assignment")
        archive_path = archive_manager.archive_version(test_file, "# Test file for version assignment\nprintln('test')\n", "First improvement")
        println(f"Archive created at: {archive_path}")
        
        # Check the archive index
        index = archive_manager.archive_index
        if test_file in index:
            file_info = index[test_file]
            println(f"File info in index: {file_info}")
            println(f"Archive count: {file_info.get('archive_count', 0)}")
            println(f"Latest version: {file_info.get('latest_version', 'None')}")
        
        # Test 2: Check what version is assigned for second improvement
        println("\nTest 2: Second improvement version assignment")
        archive_path2 = archive_manager.archive_version(test_file, "# Test file for version assignment\nprintln('test')\n", "Second improvement")
        println(f"Archive created at: {archive_path2}")
        
        # Check the archive index again
        index = archive_manager.get_archive_index()
        if test_file in index:
            file_info = index[test_file]
            println(f"File info in index: {file_info}")
            println(f"Archive count: {file_info.get('archive_count', 0)}")
            println(f"Latest version: {file_info.get('latest_version', 'None')}")
        
        # Test 3: List archive files to see naming pattern
        println("\nTest 3: Archive files listing")
        archive_files = archive_manager.list_archive_files(test_file)
        println(f"Archive files: {archive_files}")
        
        # Clean up
        os.unlink(test_file)
        archive_manager.delete_archives(test_file)
        
        return True
        
    except Exception as e:
        println(f"Version assignment test failed: {e}")
        # import traceback
        traceback.print_exc()
        return False

func test_diff_highlighting():
    """Test diff highlighting mechanism."""
    println("\n=== TESTING DIFF HIGHLIGHTING ===")
    
    try:
        # from noodlecore.desktop.ide.self_improvement_integration # import SelfImprovementIntegration
        
        # Create a mock IDE with necessary methods
        class MockIDE:
            func __init__(self):
                self.open_files = {}
                self.si_display = None
                self.ai_chat = None
                self.status_bar = None
                self.diff_highlighting_called = False
                self.file_opened = False
            
            func register_self_improvement_callback(self, callback):
                self.callback = callback
                println("[OK] Self-improvement callback registered")
            
            func _open_file_in_explorer(self, file_path):
                println(f"[OK] File opened in explorer: {file_path}")
                self.file_opened = True
                # Simulate opening file in IDE
                tab_id = f"tab_{len(self.open_files)}"
                self.open_files[tab_id] = {"path": file_path, "text": MockTextWidget()}
            
            func show_diff_highlighting(self, file_path, diff_lines, diff_summary, improvement, original_content, improved_content):
                println(f"[OK] Diff highlighting shown for file: {file_path}")
                println(f"  - Lines added: {diff_summary.get('lines_added', 0)}")
                println(f"  - Lines removed: {diff_summary.get('lines_removed', 0)}")
                println(f"  - Improvement type: {improvement.get('type', 'unknown')}")
                self.diff_highlighting_called = True
                return True
            
            func _apply_diff_highlighting_to_editor(self, file_path, diff_lines, diff_summary, improvement):
                println(f"[OK] Diff highlighting applied to editor for file: {file_path}")
                return True
            
            func update(self):
                println("[OK] IDE updated")
                pass
        
        class MockTextWidget:
            func tag_remove(self, tag, start, end):
                pass
            func tag_add(self, tag, start, end):
                pass
            func tag_configure(self, tag, **kwargs):
                pass
        
        # Create mock IDE instance
        mock_ide = MockIDE()
        
        # Create self-improvement integration
        integration = SelfImprovementIntegration(mock_ide)
        
        println("\nTest 1: Check auto_apply_improvements setting")
        println(f"Auto-apply improvements: {integration.config.get('auto_apply_improvements', 'Not set')}")
        
        println("\nTest 2: Create and apply an improvement")
        # Create a test file
        test_file = "test_diff_file.py"
        with open(test_file, 'w') as f:
            f.write("# Original test file\nfunc hello_world():\n    println('Hello, World!')\n\nif __name__ == '__main__':\n    hello_world()\n")
        
        # Create an improvement
        improvement = {
            'id': 'test_diff_improvement',
            'type': 'code_quality',
            'description': 'Test improvement for diff highlighting',
            'priority': 'medium',
            'source': 'test_system',
            'file': test_file,
            'auto_applicable': True,
            'status': 'pending'
        }
        
        # Add improvement to active list
        integration.active_improvements.append(improvement)
        
        # Apply improvement (this should trigger diff highlighting)
        integration._apply_improvement(improvement)
        
        # Check results
        println(f"Improvement status: {improvement.get('status', 'unknown')}")
        println(f"File was opened: {mock_ide.file_opened}")
        println(f"Diff highlighting was called: {mock_ide.diff_highlighting_called}")
        
        # Clean up
        os.unlink(test_file)
        
        return True
        
    except Exception as e:
        println(f"Diff highlighting test failed: {e}")
        # import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    println("Debugging version assignment and diff highlighting issues...")
    
    version_success = test_version_assignment()
    diff_success = test_diff_highlighting()
    
    println("\n=== SUMMARY ===")
    println(f"Version assignment test: {'PASSED' if version_success else 'FAILED'}")
    println(f"Diff highlighting test: {'PASSED' if diff_success else 'FAILED'}")
    
    if version_success and diff_success:
        println("\n✓ All tests passed!")
        sys.exit(0)
    else:
        println("\n- Some tests failed!")
        sys.exit(1)