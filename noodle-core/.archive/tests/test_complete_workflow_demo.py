#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_complete_workflow_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Complete Python to NoodleCore Workflow Demo

This script demonstrates the complete workflow for Python to NoodleCore conversion
with archiving and self-improvement integration.
"""

import os
import sys
import tempfile
import time
from pathlib import Path

# Add the noodle-core path to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.noodlecore.compiler.python_to_nc_workflow import get_python_to_nc_workflow


def create_sample_python_file(file_path: str) -> str:
    """Create a sample Python file for demonstration."""
    sample_code = """def calculate_fibonacci(n):
    \"\"\"Calculate the nth Fibonacci number.\"\"\"
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)

def process_data(data):
    \"\"\"Process a list of data items.\"\"\"
    result = []
    for item in data:
        if item > 0:
            result.append(item * 2)
    return result

class DataProcessor:
    \"\"\"A simple data processing class.\"\"\"
    
    def __init__(self, name):
        self.name = name
        self.processed_count = 0
    
    def process(self, data):
        \"\"\"Process data and return processed count.\"\"\"
        self.processed_count += len(data)
        return len(data)
    
    def get_status(self):
        \"\"\"Get processing status.\"\"\"
        return f"Processed {self.processed_count} items"
"""
    
    with open(file_path, 'w') as f:
        f.write(sample_code)
    
    return sample_code


def main():
    """Main demonstration function."""
    print("=" * 60)
    print("Complete Python to NoodleCore Workflow Demo")
    print("=" * 60)
    
    # Create a temporary directory for our demo
    with tempfile.TemporaryDirectory() as temp_dir_str:
        temp_dir = Path(temp_dir_str)
        
        # Create sample Python file
        python_file = temp_dir / "sample_fibonacci.py"
        create_sample_python_file(python_file)
        
        print(f"Created sample Python file: {python_file}")
        
        # Get the workflow instance
        workflow = get_python_to_nc_workflow()
        
        # Configure workflow for demo
        workflow.configure_workflow({
            "enabled": True,
            "archive_originals": True,
            "auto_optimize_nc": True,
            "register_runtime_components": True,
            "backup_before_conversion": True
        })
        
        print("Workflow configured for demo")
        print(f"Configuration: {workflow.get_workflow_status()}")
        
        # Execute the complete workflow
        print("\n1. Converting Python file to NoodleCore...")
        result = workflow.convert_python_file(str(python_file))
        
        if result["success"]:
            print("[OK] Conversion successful!")
            print(f"  - Python file: {result['python_file']}")
            print(f"  - NoodleCore file: {result['nc_file']}")
            print(f"  - Archived: {result['archived']}")
            print(f"  - Optimized: {result['optimized']}")
            print(f"  - Registered: {result['registered']}")
            print(f"  - Duration: {result['duration']:.2f} seconds")
            
            # Show the steps
            print("\nConversion steps:")
            for i, step in enumerate(result["steps"], 1):
                status = "[OK]" if step["success"] else "[FAIL]"
                print(f"  {i}. {step['step']}: {status} {step.get('message', '')}")
            
            # Show workflow statistics
            print(f"\nWorkflow Statistics:")
            status = workflow.get_workflow_status()
            print(f"  - Total conversions: {status['total_conversions']}")
            print(f"  - Successful conversions: {status['successful_conversions']}")
            print(f"  - Failed conversions: {status['failed_conversions']}")
            print(f"  - Average duration: {status['average_duration']:.2f} seconds")
            print(f"  - Last conversion: {status['last_conversion']}")
        
        return 0 if result["success"] else 1


if __name__ == "__main__":
    sys.exit(main())

