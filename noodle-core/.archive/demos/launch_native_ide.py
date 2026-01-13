#!/usr/bin/env python3
"""
Noodle Core::Launch Native Ide - launch_native_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Canonical launcher for the NoodleCore Native GUI IDE.

This script ALWAYS launches the single official IDE implementation:
src/noodlecore/desktop/ide/native_gui_ide.py::NativeNoodleCoreIDE
"""
import os
import sys


def main():
    # Ensure src/ is on sys.path
    repo_root = os.path.dirname(os.path.abspath(__file__))
    src_path = os.path.join(repo_root, "src")
    if src_path not in sys.path:
        sys.path.insert(0, src_path)

    try:
        from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
    except ImportError as e:
        print(f"âŒ Failed to import canonical IDE (native_gui_ide.py): {e}")
        print("ðŸ”§ Ensure you run this from the noodle-core directory with src/ on PYTHONPATH.")
        return 1

    print("Launching canonical NoodleCore Native GUI IDE (NativeNoodleCoreIDE)...")
    ide = NativeNoodleCoreIDE()
    return ide.run()


if __name__ == "__main__":
    raise SystemExit(main())

