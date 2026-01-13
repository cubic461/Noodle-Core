# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Noodle CLI - Command-line interface for NoodleCore

# This script serves as the main entry point for the Noodle CLI when run directly.
# It can be used as:
#     python noodle_cli.py [command] [options]

# Usage examples:
    python noodle_cli.py run "print('Hello, World!')"
#     python noodle_cli.py run --file hello.noodle
#     python noodle_cli.py build hello.noodle --output hello.nbc
# """

import sys
import os

# Add src to path to allow imports from noodlecore
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

# Import the main CLI function
import noodlecore.cli.noodle_cli.main

if __name__ == "__main__"
        sys.exit(main())