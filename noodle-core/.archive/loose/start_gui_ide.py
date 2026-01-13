#!/usr/bin/env python3
"""
Noodle Core::Start Gui Ide - start_gui_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Native GUI IDE Launcher
Bridges Python execution to pure NoodleCore (.nc) components
"""

import sys
import os
import logging
import time

# Add the src directory to Python path to access NoodleCore modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def main():
    """Start the canonical NoodleCore Native GUI IDE.

    This wrapper ensures every environment launches the same IDE:
    src/noodlecore/desktop/ide/native_gui_ide.py::NativeNoodleCoreIDE.
    """
    print("\n" + "=" * 70)
    print("ðŸš€ NOODLECORE NATIVE GUI IDE - CANONICAL PYTHON IMPLEMENTATION")
    print("=" * 70)
    print()

    # Ensure src is on sys.path
    src_path = os.path.join(os.path.dirname(__file__), 'src')
    if src_path not in sys.path:
        sys.path.insert(0, src_path)

    try:
        # Preferred import when run from repository root
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
    except ImportError:
        try:
            # Fallback if package layout differs
            from src.noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        except ImportError as e:
            print(f"âŒ Failed to import canonical IDE (native_gui_ide.py): {e}")
            print("Ensure you run this from the noodle-core directory with src/ on PYTHONPATH.")
            return 1

    print("âœ… Using canonical NativeNoodleCoreIDE from native_gui_ide.py")
    print("ðŸŽ¯ All tools (RooCode, Costrict, CLI) must use this launcher for a single unified IDE.\n")

    ide = NativeNoodleCoreIDE()
    return ide.run()

if __name__ == "__main__":
    exit(main())

