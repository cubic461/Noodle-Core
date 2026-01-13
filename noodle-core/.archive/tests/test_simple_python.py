#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_python.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Python test file for conversion to NoodleCore.
"""

def calculate_fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

def main():
    """Main function."""
    print("Testing Fibonacci calculation")
    
    for i in range(10):
        result = calculate_fibonacci(i)
        print(f"Fibonacci({i}) = {result}")

if __name__ == "__main__":
    main()

