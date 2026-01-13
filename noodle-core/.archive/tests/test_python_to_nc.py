#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_python_to_nc.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to demonstrate Python to NoodleCore conversion
"""

def hello_world():
    """Simple hello world function"""
    print("Hello from Python!")
    return "Hello World"

def calculate_sum(a, b):
    """Calculate sum of two numbers"""
    result = a + b
    print(f"Sum of {a} and {b} is {result}")
    return result

def main():
    """Main function"""
    print("Starting Python test script...")
    
    # Test hello world
    message = hello_world()
    print(f"Message: {message}")
    
    # Test calculation
    sum_result = calculate_sum(5, 3)
    print(f"Calculation result: {sum_result}")
    
    print("Python test script completed!")

if __name__ == "__main__":
    main()

