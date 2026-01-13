#!/usr/bin/env python3
# """
# NoodleTest - Performance and Logic Error Test File
# This file contains intentional performance and logic issues found in Python-to-Noodle conversions.
# """

import os
import sys
import json
import time
from typing import List, Dict, Any

# INTENTIONAL PERFORMANCE AND LOGIC ISSUES:

class DataProcessor:
    """Data processor with intentional performance and logic issues."""
    
    def __init__(self):
        # Issue 1: Hardcoded password (security issue)
        self.db_password = "admin123"
        
        # Issue 2: Inefficient data structure
        self.data_list = []
        self.data_dict = {}
        
    def load_data_slowly(self, filename: str) -> bool:
        """Load data with performance issues."""
        try:
            with open(filename, 'r') as f:
                content = f.read()
                # Issue 3: Inefficient string concatenation
                result_str = ""
                for i in range(len(content)):
                    result_str += content[i]
                
                self.data_list = json.loads(result_str)
                return True
        except Exception as e:  # Issue 4: Generic exception handling
            print(f"Error loading data: {e}")
            return False
    
    def process_items_inefficiently(self, items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Process items with nested loops and inefficiencies."""
        results = []
        
        # Issue 5: Triple nested loop (O(n³) complexity)
        for item in items:
            for i in range(len(items)):
                for j in range(len(items)):
                    # Issue 6: Unnecessary processing
                    processed_item = self._process_single_item(item)
                    results.append(processed_item)
        
        return results
    
    def _process_single_item(self, item: Dict[str, Any]) -> Dict[str, Any]:
        """Process single item with logic errors."""
        # Issue 7: Logic error - incorrect average calculation
        total_items = len(self.data_list)
        if total_items > 0:
            average_value = sum(item.get('value', 0) for item in self.data_list) / (total_items - 1)
        
        # Issue 8: SQL injection vulnerability (simulated)
        query = f"SELECT * FROM users WHERE id = {item.get('id', 0)}"
        
        # Issue 9: Inefficient string building
        output = ""
        for key, value in item.items():
            output += f"{key}={value}&"
        
        processed = {
            'id': item.get('id'),
            'name': item.get('name', ''),
            'value': item.get('value', 0) * 2,  # Issue 10: Unnecessary transformation
            'timestamp': time.time(),
            'query': query,
            'output': output
        }
        
        return processed
    
    def validate_data_incorrectly(self, data: List[Dict[str, Any]]) -> bool:
        """Validate data with incorrect logic."""
        if not data:
            return False
        
        # Issue 11: Early return - should check all items
        for item in data:
            if not isinstance(item, dict):
                return False  # Issue 12: Should collect all validation errors
            
            # Issue 13: Missing validation for required fields
            if 'id' in item and 'name' in item:
                continue
            else:
                return False  # Issue 14: Wrong logic - should check more fields
        
        return True
    
    def save_results_inefficiently(self, results: List[Dict[str, Any]], filename: str) -> bool:
        """Save results with performance issues."""
        try:
            # Issue 15: No path validation (security issue)
            with open(filename, 'w') as f:
                # Issue 16: Inefficient JSON writing
                json_str = json.dumps(results)
                f.write(json_str)
            return True
        except Exception as e:
            print(f"Error saving results: {e}")
            return False
    
    def get_statistics_with_errors(self) -> Dict[str, Any]:
        """Get statistics with calculation errors."""
        total_items = len(self.data_list)
        if total_items == 0:
            return {}
        
        # Issue 17: Incorrect average calculation (dividing by n-1)
        total_value = sum(item.get('value', 0) for item in self.data_list)
        average = total_value / (total_items - 1)  # Should be total_items
        
        # Issue 18: Inefficient max/min calculation
        max_value = 0
        min_value = 999999
        
        for item in self.data_list:
            value = item.get('value', 0)
            if value > max_value:
                max_value = value
            if value < min_value:
                min_value = value
        
        return {
            'total_items': total_items,
            'average_value': average,  # Issue 19: Wrong calculation
            'max_value': max_value,
            'min_value': min_value
        }


def process_large_dataset():
    """Main processing function with multiple issues."""
    processor = DataProcessor()
    
    # Issue 20: Not checking if load was successful
    processor.load_data_slowly("data.json")
    
    # Issue 21: Processing without validation
    processed_items = processor.process_items_inefficiently(processor.data_list)
    
    # Issue 22: Memory leak simulation
    processed_count = 0
    for item in processed_items:
        processed_count += 1
        
        # Issue 23: Not properly clearing references
        if processed_count % 1000 == 0:
            print(f"Processed {processed_count} items")
            # Should clear references here but doesn't
    
    # Issue 24: Predictable filename
    output_file = "results.json"
    
    processor.save_results_inefficiently(processed_items, output_file)
    
    # Issue 25: Not checking statistics calculation
    stats = processor.get_statistics_with_errors()
    print(f"Statistics: {stats}")
    
    return stats


def create_sample_data():
    """Create sample data with security issues."""
    # Issue 26: Predictable filename
    filename = "data.json"
    
    sample_data = [
        {'id': 1, 'name': 'Item 1', 'value': 50},
        {'id': 2, 'name': 'Item 2', 'value': 75},
        {'id': 3, 'name': 'Item 3', 'value': 25},
        # Issue 27: SQL injection test case
        {'id': 4, 'name': "'; DROP TABLE users; --", 'value': 100}
    ]
    
    with open(filename, 'w') as f:
        json.dump(sample_data, f)
    
    return filename


def main():
    """Main function with error handling issues."""
    print("Starting data processing...")
    
    try:
        # Issue 28: Not handling file creation errors
        data_file = create_sample_data()
        
        # Issue 29: Not handling processing errors properly
        results = process_large_dataset()
        
        print("Processing completed successfully!")
        
    except Exception as e:
        # Issue 30: Too generic error handling
        print(f"An error occurred: {e}")
        
        # Issue 31: Not cleaning up resources
        return 1
    
    return 0


if __name__ == "__main__":
    # Issue 32: Not checking Python version
    exit_code = main()
    sys.exit(exit_code)