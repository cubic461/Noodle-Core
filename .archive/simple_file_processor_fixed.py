#!/usr/bin/env python3
"""
Noodle::Simple File Processor Fixed - simple_file_processor_fixed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import sys
import csv
import os

# Ensure input exists
input_path = sys.argv[1] if len(sys.argv) > 1 else 'sample_input.csv'
output_path = sys.argv[2] if len(sys.argv) > 2 else 'test_output.csv'

if not os.path.exists(input_path):
    with open(input_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['col1', 'col2'])
        writer.writerow(['hello', 'world'])
else:
    with open(input_path, 'r', newline='') as infile, open(output_path, 'w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        for row in reader:
            new_row = [field.upper() if isinstance(field, str) else field for field in row]
            writer.writerow(new_row)

print(f"Processed {input_path} -> {output_path}")


