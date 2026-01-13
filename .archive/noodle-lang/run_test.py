#!/usr/bin/env python3
"""
Test Suite::Noodle Lang - run_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import os
import sys
from pathlib import Path

# Voeg compiler toe aan pad
sys.path.insert(0, str(Path(__file__).parent / "src"))

from noodle_lang.compiler import NoodleCompiler
from noodle_lang.lexer import NoodleLexer
from noodle_lang.parser import NoodleParser

# Kort test script
test_file = "hello_world_fix.nc"

print("Testing compiler met", test_file)

# Compiler aanroepen
compiler = NoodleCompiler(optimize=True, debug=False)
result = compiler.compile_file(test_file)

if result.success:
    print(f"âœ… Compilatie gelukt!")
    print(f"   Tijd: {result.compilation_time:.3f}s")
    print(f"   Instructies: {result.statistics['instructions']}")
    print(f"   Constants: {result.statistics['constants']}")
    print(f"   Optimizations: {result.statistics['optimizations']}")
else:
    print(f"âŒ Compilatie mislukt:")
    for error in result.errors:
        print(f"   Error: {error.location.file}:{error.location.line}:{error.location.column}: {error.message}")


