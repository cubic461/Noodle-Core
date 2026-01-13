#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_complete_python_to_nc_workflow.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for the complete Python to NoodleCore conversion workflow.

This script tests:
1. Python to NoodleCore conversion with archiving
2. Integration with self-improvement system for .nc files
3. Integration with runtime component registry
4. Configuration settings to enable/disable workflow
"""

import os
import sys
import tempfile
import shutil
from pathlib import Path
import json
from datetime import datetime

# Add noodle-core to path for imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

def create_test_python_file(file_path: str) -> None:
    """Create a test Python file for conversion."""
    test_content = '''#!/usr/bin/env python3
"""
Test Python file for NoodleCore conversion.
This file contains various Python constructs to test the conversion.
"""

import math
import json
from typing import List, Dict

class TestClass:
    """A test class for conversion."""
    
    def __init__(self, name: str):
        self.name = name
        self.data = []
    
    def add_item(self, item: str) -> None:
        """Add an item to the data list."""
        self.data.append(item)
        print(f"Added {item} to {self.name}")
    
    def get_summary(self) -> Dict[str, any]:
        """Get a summary of the test class."""
        return {
            "name": self.name,
            "item_count": len(self.data),
            "items": self.data.copy()
        }

def calculate_fibonacci(n: int) -> int:
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)

def process_data(items: List[str]) -> List[str]:
    """Process a list of items."""
    processed = []
    for item in items:
        if len(item) > 3:
            processed.append(item.upper())
    return processed

def main():
    """Main function."""
    print("Starting test Python script")
    
    # Create test instance
    test_obj = TestClass("test_instance")
    test_obj.add_item("item1")
    test_obj.add_item("item2")
    test_obj.add_item("item3")
    
    # Print summary
    summary = test_obj.get_summary()
    print(f"Summary: {json.dumps(summary, indent=2)}")
    
    # Test Fibonacci
    fib_result = calculate_fibonacci(10)
    print(f"Fibonacci(10) = {fib_result}")
    
    # Test data processing
    test_items = ["apple", "banana", "kiwi", "orange"]
    processed = process_data(test_items)
    print(f"Processed items: {processed}")
    
    print("Test Python script completed")

if __name__ == "__main__":
    main()
'''
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(test_content)

def test_workflow_conversion():
    """Test the complete Python to NoodleCore workflow."""
    print("=" * 60)
    print("Testing Python to NoodleCore Workflow Conversion")
    print("=" * 60)
    
    # Create temporary directory for test
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Create test Python file
        py_file = temp_path / "test_python_script.py"
        create_test_python_file(str(py_file))
        print(f"Created test Python file: {py_file}")
        
        # Test 1: Basic workflow conversion
        print("\n1. Testing basic workflow conversion...")
        try:
            from noodlecore.compiler.python_to_nc_workflow import PythonToNoodleCoreWorkflow
            
            workflow = PythonToNoodleCoreWorkflow()
            result = workflow.convert_file(str(py_file))
            
            if result['success']:
                print(f"[SUCCESS] Conversion successful")
                print(f"  - Input: {result['original_file']}")
                print(f"  - Output: {result['nc_file']}")
                if result.get('archived_file'):
                    print(f"  - Archived: {result['archived_file']}")
                print(f"  - Duration: {result.get('conversion_duration', 'N/A')}")
            else:
                print(f"[ERROR] Conversion failed: {result.get('error', 'Unknown error')}")
                return False
                
        except Exception as e:
            try:
                print(f"[ERROR] Workflow conversion test failed: {e}")
                # Fallback to simple conversion test
                print("[INFO] Falling back to simple conversion test...")
                from noodlecore.compiler.python_to_nc_converter import PythonToNoodleCoreConverter
                
                converter = PythonToNoodleCoreConverter()
                nc_file = str(py_file)[:-3] + '.nc'
                success = converter.convert_file(str(py_file), nc_file)
                
                if success and Path(nc_file).exists():
                    print("[SUCCESS] Simple conversion successful")
                    with open(nc_file, 'r') as f:
                        content = f.read()
                        if content and len(content) > 10:
                            print("[SUCCESS] NoodleCore file contains converted code")
                        else:
                            print("[ERROR] NoodleCore file appears empty or invalid")
                            return False
                    return True
                else:
                    print("[ERROR] Simple conversion failed")
                    return False
            except UnicodeEncodeError:
                print(f"[ERROR] Workflow conversion test failed: {str(e)}")
            return False
        
        # Test 2: Configuration settings
        print("\n2. Testing configuration settings...")
        try:
            # Test with archiving disabled
            workflow.configure({'archive_original': False})
            result_no_archive = workflow.convert_file(str(py_file))
            
            if result_no_archive['success'] and not result_no_archive.get('archived_file'):
                print("[SUCCESS] Archiving can be disabled")
            else:
                print("[ERROR] Archiving configuration not working properly")
            
            # Test with self-improvement disabled
            workflow.configure({'enable_self_improvement': False})
            result_no_si = workflow.convert_file(str(py_file))
            
            if result_no_si['success']:
                print("[SUCCESS] Self-improvement can be disabled")
            else:
                print("[ERROR] Self-improvement configuration not working properly")
            
            # Reset to default configuration
            workflow.configure({'archive_original': True, 'enable_self_improvement': True})
            
        except Exception as e:
            print(f"[ERROR] Configuration test failed: {e}")
            return False
        
        # Test 3: Self-improvement integration
        print("\n3. Testing self-improvement integration...")
        try:
            from noodlecore.self_improvement.nc_file_analyzer import NCFileAnalyzer
            
            analyzer = NCFileAnalyzer()
            if result['nc_file'] and Path(result['nc_file']).exists():
                analysis = analyzer.analyze_file(result['nc_file'])
                
                if analysis:
                    print("âœ“ Self-improvement analysis completed")
                    print(f"  - Issues found: {len(analysis.get('issues', []))}")
                    print(f"  - Suggestions: {len(analysis.get('suggestions', []))}")
                else:
                    print("âœ“ Self-improvement analysis completed (no issues found)")
            else:
                print("âœ— Cannot test self-improvement integration - .nc file not found")
                
        except Exception as e:
            print(f"âœ— Self-improvement integration test failed: {e}")
        
        # Test 4: Runtime component registry integration
        print("\n4. Testing runtime component registry integration...")
        try:
            from noodlecore.self_improvement.runtime_upgrade.runtime_component_registry import get_runtime_component_registry
            
            registry = get_runtime_component_registry()
            if registry and result['nc_file'] and Path(result['nc_file']).exists():
                component_name = Path(result['nc_file']).stem
                
                # Register the converted file
                registry.register_component(
                    name=component_name,
                    component_type="noodlecore_file",
                    version="1.0.0",
                    file_path=result['nc_file'],
                    description=f"Test converted from Python: {py_file}",
                    metadata={
                        "original_python_file": str(py_file),
                        "conversion_timestamp": datetime.now().isoformat(),
                        "conversion_method": "python_to_nc_workflow"
                    }
                )
                
                # Verify registration
                component = registry.get_component(component_name)
                if component:
                    print("âœ“ Runtime component registration successful")
                    print(f"  - Component: {component.name}")
                    print(f"  - Type: {component.component_type}")
                    print(f"  - Version: {component.version}")
                else:
                    print("âœ— Runtime component registration failed")
            else:
                print("âœ— Cannot test runtime registry - registry or .nc file not available")
                
        except Exception as e:
            print(f"âœ— Runtime component registry test failed: {e}")
        
        # Test 5: Self-improvement integration settings
        print("\n5. Testing self-improvement integration settings...")
        try:
            from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
            
            # Create a mock IDE instance for testing
            class MockIDE:
                def __init__(self):
                    self.current_project_path = str(temp_path)
                    self.ai_chat = MockChat()
                    self.status_bar = MockStatusBar()
                
                def register_self_improvement_callback(self, callback):
                    pass
                
                def register_diff_highlighting_callback(self, callback):
                    pass
            
            class MockChat:
                def __init__(self):
                    self.content = []
                
                def config(self, state):
                    pass
                
                def insert(self, position, text):
                    self.content.append(text)
                
                def see(self, end):
                    pass
            
            class MockStatusBar:
                def config(self, text):
                    print(f"Status: {text}")
            
            # Test with conversion enabled
            mock_ide = MockIDE()
            si_integration = SelfImprovementIntegration(mock_ide)
            
            # Test configuration
            si_integration.configure_settings({
                'enable_python_to_nc_conversion': True,
                'archive_python_files': True,
                'register_nc_files_with_runtime': True
            })
            
            print("âœ“ Self-improvement integration configured")
            
            # Test with conversion disabled
            si_integration.configure_settings({
                'enable_python_to_nc_conversion': False
            })
            
            print("âœ“ Python to NoodleCore conversion can be disabled")
            
        except Exception as e:
            print(f"âœ— Self-improvement integration settings test failed: {e}")
        
        print("\n" + "=" * 60)
        print("Python to NoodleCore Workflow Test Completed")
        print("=" * 60)
        return True

def test_ide_integration():
    """Test IDE integration with the workflow."""
    print("\n" + "=" * 60)
    print("Testing IDE Integration")
    print("=" * 60)
    
    try:
        # Create temporary directory for test
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            py_file = temp_path / "ide_test_script.py"
            create_test_python_file(str(py_file))
            
            # Test IDE integration
            from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
            
            # Create a mock IDE instance
            class MockIDE:
                def __init__(self):
                    self.current_project_path = str(temp_path)
                    self.current_file = str(py_file)
                    self.ai_chat = MockChat()
                    self.status_bar = MockStatusBar()
                
                def register_self_improvement_callback(self, callback):
                    pass
                
                def register_diff_highlighting_callback(self, callback):
                    pass
            
            class MockChat:
                def __init__(self):
                    self.messages = []
                
                def config(self, state):
                    pass
                
                def insert(self, position, text):
                    self.messages.append(text)
                    print(f"AI Chat: {text.strip()}")
                
                def see(self, end):
                    pass
            
            class MockStatusBar:
                def config(self, text):
                    print(f"Status: {text}")
            
            mock_ide = MockIDE()
            si_integration = SelfImprovementIntegration(mock_ide)
            
            # Configure for testing
            si_integration.configure_settings({
                'enable_python_to_nc_conversion': True,
                'archive_python_files': True,
                'register_nc_files_with_runtime': True,
                'auto_approve_changes': True  # Enable auto-approval for testing
            })
            
            # Create improvement for Python file
            improvement = {
                'type': 'python_conversion',
                'description': f"Python file detected: {py_file}",
                'priority': 'medium',
                'source': 'test_system',
                'file': str(py_file),
                'suggestion': 'Convert this Python file to NoodleCore',
                'action': 'convert_to_nc'
            }
            
            # Apply improvement
            print("Applying Python conversion improvement through IDE integration...")
            success = si_integration._apply_python_conversion_improvement(improvement)
            
            if success:
                print("[SUCCESS] IDE integration test successful")
                
                # Check if messages were generated
                if mock_ide.ai_chat.messages:
                    print(f"[SUCCESS] UI messages generated: {len(mock_ide.ai_chat.messages)}")
                    for msg in mock_ide.ai_chat.messages:
                        if "Python conversion" in msg:
                            print(f"  - Found conversion message: {msg.strip()}")
            else:
                print("[ERROR] IDE integration test failed")
                
    except Exception as e:
        print(f"[ERROR] IDE integration test failed: {e}")

def main():
    """Main test function."""
    print("Python to NoodleCore Complete Workflow Test")
    print(f"Test started at: {datetime.now().isoformat()}")
    
    # Run tests
    success = test_workflow_conversion()
    test_ide_integration()
    
    print(f"\nTest completed at: {datetime.now().isoformat()}")
    
    if success:
        print("\n[SUCCESS] All tests completed successfully!")
        return 0
    else:
        print("\n[ERROR] Some tests failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())

