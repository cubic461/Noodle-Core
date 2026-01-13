#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_python_conversion.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Python file for conversion to NoodleCore format.
This file contains various Python constructs to test the converter.
"""

import math
import random
from typing import List, Dict

def calculate_fibonacci(n: int) -> int:
    """Calculate the nth Fibonacci number."""
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

def process_data(data: List[Dict]) -> List[Dict]:
    """Process a list of data dictionaries."""
    result = []
    for item in data:
        # Calculate some metrics
        item['processed'] = True
        item['score'] = random.random() * 100
        item['sqrt_value'] = math.sqrt(item.get('value', 0))
        result.append(item)
    
    print(f"Processed {len(result)} items")
    return result

class DataProcessor:
    """A simple data processing class."""
    
    def __init__(self, name: str):
        self.name = name
        self.data = []
    
    def add_data(self, item: Dict):
        """Add a data item."""
        self.data.append(item)
        print(f"Added item to {self.name}")
    
    def get_summary(self) -> Dict:
        """Get a summary of the data."""
        if not self.data:
            return {"count": 0, "total": 0}
        
        total = sum(item.get('value', 0) for item in self.data)
        return {
            "count": len(self.data),
            "total": total,
            "average": total / len(self.data)
        }

def main():
    """Main function to demonstrate the functionality."""
    # Test data
    test_data = [
        {"id": 1, "value": 10, "category": "A"},
        {"id": 2, "value": 25, "category": "B"},
        {"id": 3, "value": 15, "category": "A"}
    ]
    
    # Process data
    processed_data = process_data(test_data)
    
    # Create processor
    processor = DataProcessor("TestProcessor")
    for item in processed_data:
        processor.add_data(item)
    
    # Get summary
    summary = processor.get_summary()
    print(f"Summary: {summary}")
    
    # Test Fibonacci
    fib_result = calculate_fibonacci(10)
    print(f"Fibonacci(10) = {fib_result}")

if __name__ == "__main__":
    main()

