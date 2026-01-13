#!/usr/bin/env python3
"""
Native::Launch Native Ide - launch_native_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Native GUI IDE Launcher
Launches the native GUI IDE from the proper noodle-ide directory structure
"""

import sys
import os
from pathlib import Path

# Add the src directory to Python path for imports
current_dir = Path(__file__).parent
src_dir = current_dir / 'src'
sys.path.insert(0, str(src_dir))

try:
    from nativegui.native_gui_ide import NativeNoodleCoreIDE
    
    def main():
        """Main entry point to launch the IDE."""
        print("ðŸš€ Starting NoodleCore Native GUI IDE...")
        print("ðŸ“ Location: noodle-ide/native")
        print("ðŸ”§ Features: Resizable windows, AI integration, file operations")
        print("-" * 60)
        
        try:
            ide = NativeNoodleCoreIDE()
            return ide.run()
        except Exception as e:
            print(f"âŒ Failed to start IDE: {e}")
            return 1
    
    if __name__ == "__main__":
        exit(main())

except ImportError as e:
    print(f"âŒ Import error: {e}")
    print("ðŸ’¡ Make sure you're running from the noodle-ide/native directory")
    sys.exit(1)

