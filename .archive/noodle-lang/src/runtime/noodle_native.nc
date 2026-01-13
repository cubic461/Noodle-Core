# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Native NoodleCore Runtime - Standalone Script
# ----------------------------------------------

# This script provides a standalone entry point for the native NoodleCore runtime.
# It demonstrates that NoodleCore works independently of Python wrappers.

# Usage:
#     python noodle_native.py run --file examples/hello_world.noodle
#     python noodle_native.py build examples/hello_world.noodle --output hello.nbc
#     python noodle_native.py execute hello.nbc
# """

import sys
import os

# Add src to path to allow imports from noodlecore
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

# Import the main CLI function
import noodlecore.cli.native_cli.main

if __name__ == "__main__"
        sys.exit(main())