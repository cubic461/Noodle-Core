#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_diff_auto_original.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test file for automatic diff highlighting functionality.

This file contains intentional inefficiencies and poor coding practices
to test if the self-improvement system detects and improves them
with proper diff highlighting in the IDE.
"""

import os
import sys
import time

# Poor variable naming and inefficient loop
def calculate_sum(numbers_list):
    # Inefficient loop with bad variable names
    total_sum = 0
    for i in range(len(numbers_list)):
        total_sum = total_sum + numbers_list[i]
        time.sleep(0.001)  # Unnecessary delay
    return total_sum

# Redundant function with poor structure
def find_maximum_value(input_data):
    max_val = input_data[0]
    for item in input_data:
        if item > max_val:
            max_val = item
    return max_val

# Inefficient string concatenation
def build_string_output(data_list):
    result_string = ""
    for item in data_list:
        result_string = result_string + str(item) + " "
    return result_string

# Poor error handling
def read_file_content(file_path):
    try:
        file_handle = open(file_path, 'r')
        content = file_handle.read()
        file_handle.close()
        return content
    except:
        return None

# Main execution with poor practices
if __name__ == "__main__":
    # Hardcoded values
    test_data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    # Inefficient calculations
    sum_result = calculate_sum(test_data)
    max_result = find_maximum_value(test_data)
    string_result = build_string_output(test_data)
    
    # Poor output formatting
    print("Results:")
    print("Sum: " + str(sum_result))
    print("Max: " + str(max_result))
    print("String: " + string_result)
    
    # File operations without proper error handling
    file_content = read_file_content("nonexistent_file.txt")
    if file_content is not None:
        print("File content: " + file_content)
    else:
        print("File not found (but no proper error handling)")

