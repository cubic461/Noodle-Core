#!/usr/bin/env python3
"""
Launchers::Start Ide - start_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Native GUI IDE Launcher
Main entry point for launching the IDE from the proper directory structure.
"""

import sys
import os
from pathlib import Path

# Add the src directory to Python path
current_dir = Path(__file__).parent.parent
src_dir = current_dir / "src"
sys.path.insert(0, str(src_dir))

# Import and launch the IDE
try:
    from nativegui import NativeNoodleCoreIDE
    
    def main():
        """Main launcher function."""
        print("ðŸš€ Starting NoodleCore Native GUI IDE v2.0...")
        print("ðŸ“‚ Working directory:", Path.cwd())
        print("ðŸ“¦ Module path:", src_dir)
        
        try:
            # Create and run IDE
            ide = NativeNoodleCoreIDE()
            return ide.main()
            
        except KeyboardInterrupt:
            print("\nðŸ‘‹ IDE closed by user")
            return 0
            
        except Exception as e:
            print(f"âŒ Error starting IDE: {e}")
            import traceback
            traceback.print_exc()
            return 1

    if __name__ == "__main__":
        sys.exit(main())

except ImportError as e:
    print(f"âŒ Import error: {e}")
    print(f"Current working directory: {Path.cwd()}")
    print(f"Python path: {sys.path}")
    print(f"Looking for modules in: {src_dir}")
    
    # Fallback: Try direct execution
    print("\nðŸ”„ Trying fallback launch...")
    fallback_file = current_dir / "src" / "nativegui" / "native_gui_ide.py"
    if fallback_file.exists():
        print(f"Running {fallback_file} directly...")
        os.system(f"python {fallback_file}")
    else:
        print(f"âŒ Fallback file not found: {fallback_file}")
        sys.exit(1)

except Exception as e:
    print(f"âŒ Fatal error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

