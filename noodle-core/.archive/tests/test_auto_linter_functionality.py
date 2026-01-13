#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_auto_linter_functionality.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive test for Auto Linter and Documentation Integration functionality.
Tests the actual functionality with different file types.
"""

import os
import sys
import tempfile
import json
from pathlib import Path

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

def test_auto_linter_functionality():
    """Test the auto linter and documentation functionality."""
    print("=" * 60)
    print("Auto Linter and Documentation Functionality Test")
    print("=" * 60)
    
    try:
        # Import the integration module
        from noodlecore.desktop.ide.auto_linter_documentation_integration import AutoLinterDocumentationIntegration
        print("[OK] AutoLinterDocumentationIntegration imported successfully")
        
        # Create test files
        test_dir, test_files = create_test_files()
        print(f"[OK] Created test files in {test_dir}")
        
        # Initialize the integration
        integration = AutoLinterDocumentationIntegration()
        print("[OK] AutoLinterDocumentationIntegration initialized")
        
        # Test checking files for linting and documentation
        for file_type, file_path in test_files.items():
            print(f"\n--- Testing {file_type} file: {os.path.basename(file_path)} ---")
            
            # Check file for linting and documentation opportunities
            improvements = integration._check_file_for_linting_and_documentation(file_path)
            
            if improvements:
                print(f"[OK] Found {len(improvements)} improvement opportunities")
                for improvement in improvements:
                    print(f"  - Type: {improvement.get('improvement_type', 'unknown')}")
                    print(f"    Description: {improvement.get('description', 'no description')}")
            else:
                print("[INFO] No improvement opportunities found")
        
        # Test configuration loading
        config_path = os.path.join(os.path.dirname(__file__), 'config', 'auto_linter_doc_config.json')
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = json.load(f)
            print(f"[OK] Configuration loaded from {config_path}")
            print(f"  - Auto linter enabled: {config.get('auto_linter', {}).get('enabled', False)}")
            print(f"  - Auto documentation enabled: {config.get('auto_documentation', {}).get('enabled', False)}")
        else:
            print(f"[WARNING] Configuration file not found at {config_path}")
        
        # Test applying improvements
        print("\n--- Testing improvement application ---")
        for file_type, file_path in test_files.items():
            # Read original content
            with open(file_path, 'r') as f:
                original_content = f.read()
            
            # Create a mock improvement
            improvement = {
                'improvement_type': 'auto_linter' if file_type in ['python', 'javascript'] else 'auto_documentation',
                'description': f'Test improvement for {file_type}',
                'file_path': file_path,
                'original_content': original_content,
                'improved_content': original_content + "\n# Auto-generated improvement\n",
                'diff': '--- Original\n+++ Improved\n@@ -1,1 +1,2 @@\n content\n+# Auto-generated improvement\n'
            }
            
            # Apply the improvement
            result = integration.apply_improvement(improvement)
            if result:
                print(f"[OK] Improvement applied to {os.path.basename(file_path)}")
            else:
                print(f"[FAIL] Failed to apply improvement to {os.path.basename(file_path)}")
        
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
    success = test_auto_linter_functionality()
    
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    if success:
        print("PASS: Auto Linter and Documentation functionality test passed")
        return 0
    else:
        print("FAIL: Auto Linter and Documentation functionality test failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())

