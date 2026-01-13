#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_import_fixes.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify import fixes for native_gui_ide.py
"""

import sys
import os
from pathlib import Path

# Add the project root to Python path
CURRENT_DIR = Path(__file__).parent
SRC_DIR = CURRENT_DIR / "src"
REPO_ROOT = CURRENT_DIR

for p in (str(REPO_ROOT), str(SRC_DIR)):
    if p not in sys.path:
        sys.path.insert(0, p)

print("Testing import fixes for native_gui_ide.py...")
print("=" * 60)

# Test 1: Progress Manager import
print("\n1. Testing Progress Manager import...")
try:
    from noodlecore.desktop.ide.progress_manager import ProgressManager
    print("   [OK] Progress Manager import successful")
except ImportError as e:
    print(f"   [ERROR] Progress Manager import failed: {e}")

# Test 2: Enhanced Syntax Fixer imports
print("\n2. Testing Enhanced Syntax Fixer imports...")

# Test V3
try:
    from noodlecore.desktop.ide.enhanced_syntax_fixer_v3 import EnhancedNoodleCoreSyntaxFixerV3
    print("   [OK] Enhanced Syntax Fixer V3 import successful")
except ImportError as e:
    print(f"   [ERROR] Enhanced Syntax Fixer V3 import failed: {e}")

# Test V2
try:
    from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
    print("   [OK] Enhanced Syntax Fixer V2 import successful")
except ImportError as e:
    print(f"   [ERROR] Enhanced Syntax Fixer V2 import failed: {e}")

# Test V1
try:
    from noodlecore.desktop.ide.enhanced_syntax_fixer import EnhancedNoodleCoreSyntaxFixer
    print("   [OK] Enhanced Syntax Fixer V1 import successful")
except ImportError as e:
    print(f"   [ERROR] Enhanced Syntax Fixer V1 import failed: {e}")

# Test 3: Self-Improvement Integration import
print("\n3. Testing Self-Improvement Integration import...")
try:
    from noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
    print("   [OK] Self-Improvement Integration import successful")
except ImportError as e:
    print(f"   [ERROR] Self-Improvement Integration import failed: {e}")

# Test 4: TRM Controller Integration import
print("\n4. Testing TRM Controller Integration import...")
try:
    from noodlecore.desktop.ide.trm_controller_integration import TRMControllerIntegration
    print("   [OK] TRM Controller Integration import successful")
except ImportError as e:
    print(f"   [ERROR] TRM Controller Integration import failed: {e}")

# Test 5: TRM Agent import
print("\n5. Testing TRM Agent import...")
try:
    from noodlecore.noodlecore_trm_agent import TRMAgent
    print("   [OK] TRM Agent import successful")
except ImportError as e:
    print(f"   [ERROR] TRM Agent import failed: {e}")

print("\n" + "=" * 60)
print("Import testing complete!")

