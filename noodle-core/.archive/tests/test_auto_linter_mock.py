#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_auto_linter_mock.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Mock test for Auto Linter and Documentation Integration functionality.
Tests the integration with mock implementations of enterprise modules.
"""

import os
import sys
import tempfile
import json
from pathlib import Path
from unittest.mock import Mock, MagicMock

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def create_test_files():
    """Create test files for different file types."""
    test_dir = tempfile.mkdtemp(prefix="noodle_auto_linter_test_")
    
    # Python file with linting issues
    python_file = os.path.join(test_dir, "test_lint.py")
    with open(python_file, 'w') as f:
        f.write("""
import os,sys
def test_function( x,y ):
    return x+y
class TestClass:
    def __init__(self):
        self.value=0
""")
    
    # JavaScript file with linting issues
    js_file = os.path.join(test_dir, "test_lint.js")
    with open(js_file, 'w') as f:
        f.write("""
function testFunction(x,y){
    return x+y;
}
var testClass = {
    value:0,
    getValue:function(){
        return this.value;
    }
};
""")
    
    # Markdown file without documentation
    md_file = os.path.join(test_dir, "test.md")
    with open(md_file, 'w') as f:
        f.write("""
# Test File

This is a test file with some code.

```python
def example():
    return "example"
```

Some more text here.
""")
    
    return test_dir, {
        'python': python_file,
        'javascript': js_file,
        'markdown': md_file
    }

def test_auto_linter_with_mocks():
    """Test the auto linter and documentation functionality with mocks."""
    print("=" * 60)
    print("Auto Linter and Documentation Mock Test")
    print("=" * 60)
    
    try:
        # Import the integration module
        from noodlecore.desktop.ide.auto_linter_documentation_integration import AutoLinterDocumentationIntegration
        print("[OK] AutoLinterDocumentationIntegration imported successfully")
        
        # Create test files
        test_dir, test_files = create_test_files()
        print(f"[OK] Created test files in {test_dir}")
        
        # Mock the enterprise modules
        mock_linter = Mock()
        mock_linter.lint_file.return_value = Mock(
            success=True,
            errors=[
                Mock(code='E001', message='Unused import os', line=1, column=1, severity='error'),
                Mock(code='E002', message='Missing docstring', line=3, column=1, severity='warning')
            ],
            warnings=[
                Mock(code='W001', message='Line too long', line=4, column=1, severity='warning')
            ]
        )
        
        mock_doc_integration = Mock()
        mock_doc_integration.generate_documentation.return_value = {
            'success': True,
            'documentation_items': [
                Mock(
                    kind='function',
                    name='test_function',
                    signature='test_function(x, y)',
                    content='Test function that adds two numbers',
                    parameters=[
                        {'name': 'x', 'description': 'First number'},
                        {'name': 'y', 'description': 'Second number'}
                    ],
                    returns='Sum of x and y'
                )
            ]
        }
        
        # Initialize the integration
        integration = AutoLinterDocumentationIntegration()
        
        # Replace the enterprise components with mocks
        integration.linter_api = mock_linter
        integration.documentation_integration = mock_doc_integration
        
        print("[OK] AutoLinterDocumentationIntegration initialized with mocks")
        
        # Test checking files for linting and documentation opportunities
        for file_type, file_path in test_files.items():
            print(f"\n--- Testing {file_type} file: {os.path.basename(file_path)} ---")
            
            # Check file for linting and documentation opportunities
            improvements = []
            
            # Test linting
            if integration.config.get("enable_auto_linter", False):
                lint_improvement = integration._lint_file_and_create_improvement(file_path)
                if lint_improvement:
                    improvements.append(lint_improvement)
                    print(f"[OK] Found linting improvement: {lint_improvement.get('description')}")
                else:
                    print("[INFO] No linting improvements found")
            
            # Test documentation
            if integration.config.get("enable_auto_documentation", False):
                doc_improvement = integration._generate_documentation_and_create_improvement(file_path)
                if doc_improvement:
                    improvements.append(doc_improvement)
                    print(f"[OK] Found documentation improvement: {doc_improvement.get('description')}")
                else:
                    print("[INFO] No documentation improvements found")
            
            # Test applying improvements
            for improvement in improvements:
                # Create a mock improvement with file path
                mock_improvement = {
                    'improvement_type': improvement.get('type'),
                    'description': improvement.get('description'),
                    'file_path': file_path,
                    'original_content': f"Original content for {os.path.basename(file_path)}",
                    'improved_content': f"Improved content for {os.path.basename(file_path)}",
                    'diff': '--- Original\n+++ Improved\n@@ -1,1 +1,2 @@\n content\n+ improvement\n'
                }
                
                # Test the apply_improvement method
                result = integration.apply_improvement(mock_improvement)
                if result:
                    print(f"[OK] Improvement applied to {os.path.basename(file_path)}")
                else:
                    print(f"[FAIL] Failed to apply improvement to {os.path.basename(file_path)}")
        
        # Test configuration loading
        config_path = os.path.join(os.path.dirname(__file__), 'config', 'auto_linter_doc_config.json')
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = json.load(f)
            print(f"[OK] Configuration loaded from {config_path}")
            print(f"  - Auto linter enabled: {config.get('enable_auto_linter', False)}")
            print(f"  - Auto documentation enabled: {config.get('enable_auto_documentation', False)}")
        else:
            print(f"[WARNING] Configuration file not found at {config_path}")
        
        # Test statistics
        stats = integration.get_statistics()
        print(f"[OK] Statistics: {stats}")
        
        # Test shutdown
        integration.shutdown()
        print("[OK] AutoLinterDocumentationIntegration shut down successfully")
        
        # Clean up test files
        import shutil
        shutil.rmtree(test_dir)
        print(f"[OK] Cleaned up test directory {test_dir}")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Test failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Main test function."""
    success = test_auto_linter_with_mocks()
    
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    if success:
        print("PASS: Auto Linter and Documentation mock test passed")
        return 0
    else:
        print("FAIL: Auto Linter and Documentation mock test failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())

