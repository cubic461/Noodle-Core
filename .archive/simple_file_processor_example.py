#!/usr/bin/env python3
"""
Noodle::Simple File Processor Example - simple_file_processor_example.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple File Processor Example

This demonstrates a basic file processing workflow that can be traced
and converted to a golden test for regression testing.

The processor:
1. Reads an input text file
2. Converts text to uppercase
3. Writes result to output file
4. Logs processing statistics
"""

import sys
import argparse
from pathlib import Path
import time


class SimpleFileProcessor:
    """Simple text file processor for demonstration."""
    
    def __init__(self, input_path: str, output_path: str):
        self.input_path = Path(input_path)
        self.output_path = Path(output_path)
        self.stats = {
            'lines_processed': 0,
            'characters_processed': 0,
            'start_time': None,
            'end_time': None
        }
    
    def validate_input(self) -> bool:
        """Validate input file exists and is readable."""
        if not self.input_path.exists():
            print(f"Error: Input file does not exist: {self.input_path}")
            return False
        
        if not self.input_path.is_file():
            print(f"Error: Input path is not a file: {self.input_path}")
            return False
        
        return True
    
    def create_output_directory(self):
        """Create output directory if it doesn't exist."""
        self.output_path.parent.mkdir(parents=True, exist_ok=True)
    
    def process_file(self) -> bool:
        """Process the input file and write output."""
        self.stats['start_time'] = time.time()
        
        try:
            # Read input file
            with open(self.input_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Process content (convert to uppercase)
            processed_content = content.upper()
            
            # Update statistics
            self.stats['lines_processed'] = len(content.split('\n'))
            self.stats['characters_processed'] = len(content)
            
            # Create output directory
            self.create_output_directory()
            
            # Write output file
            with open(self.output_path, 'w', encoding='utf-8') as f:
                f.write(processed_content)
            
            self.stats['end_time'] = time.time()
            return True
            
        except Exception as e:
            print(f"Error processing file: {e}")
            return False
    
    def print_stats(self):
        """Print processing statistics."""
        duration = self.stats['end_time'] - self.stats['start_time'] if self.stats['end_time'] else 0
        
        print("=" * 50)
        print("Processing Statistics")
        print("=" * 50)
        print(f"Lines processed: {self.stats['lines_processed']}")
        print(f"Characters processed: {self.stats['characters_processed']}")
        print(f"Duration: {duration:.3f} seconds")
        print(f"Output file: {self.output_path}")
        print("=" * 50)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Simple file processor - convert text to uppercase"
    )
    
    parser.add_argument(
        'input_file',
        help='Path to input text file'
    )
    
    parser.add_argument(
        'output_file',
        help='Path to output file'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )
    
    args = parser.parse_args()
    
    # Create processor
    processor = SimpleFileProcessor(args.input_file, args.output_file)
    
    # Validate input
    if not processor.validate_input():
        sys.exit(1)
    
    # Process file
    print(f"Processing: {args.input_file}")
    success = processor.process_file()
    
    if success:
        print(f"[OK] Successfully processed file")
        if args.verbose:
            processor.print_stats()
        sys.exit(0)
    else:
        print(f"[ERROR] Failed to process file")
        sys.exit(1)


if __name__ == "__main__":
    main()


