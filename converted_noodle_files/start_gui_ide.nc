# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore Native GUI IDE Launcher
Bridges Python execution to pure NoodleCore (.nc) components
# """

import sys
import os
import logging
import time

# Add the src directory to Python path to access NoodleCore modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

function main()
    #     """Start the canonical NoodleCore Native GUI IDE.

    #     This wrapper ensures every environment launches the same IDE:
    #     src/noodlecore/desktop/ide/native_gui_ide.py::NativeNoodleCoreIDE.
    #     """
    print("\n" + " = " * 70)
        print("🚀 NOODLECORE NATIVE GUI IDE - CANONICAL PYTHON IMPLEMENTATION")
    print(" = " * 70)
        print()

    #     # Ensure src is on sys.path
    src_path = os.path.join(os.path.dirname(__file__), 'src')
    #     if src_path not in sys.path:
            sys.path.insert(0, src_path)

    #     try:
    #         # Preferred import when run from repository root
    #         from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
    #     except ImportError:
    #         try:
    #             # Fallback if package layout differs
    #             from src.noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
    #         except ImportError as e:
                print(f"❌ Failed to import canonical IDE (native_gui_ide.py): {e}")
    #             print("Ensure you run this from the noodle-core directory with src/ on PYTHONPATH.")
    #             return 1

        print("✅ Using canonical NativeNoodleCoreIDE from native_gui_ide.py")
    #     print("🎯 All tools (RooCode, Costrict, CLI) must use this launcher for a single unified IDE.\n")

    ide = NativeNoodleCoreIDE()
        return ide.run()

if __name__ == "__main__"
        exit(main())