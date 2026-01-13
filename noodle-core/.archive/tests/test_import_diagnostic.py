#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_import_diagnostic.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Import Diagnostic Script for NoodleCore IDE AI Configuration

This script tests the import chain for AI configuration to identify where import errors occur.
"""

import sys
import os
import traceback
from pathlib import Path

# Add the src directory to Python path
CURRENT_DIR = Path(__file__).parent
REPO_ROOT = CURRENT_DIR
SRC_DIR = REPO_ROOT / "src"

for p in (str(REPO_ROOT), str(SRC_DIR)):
    if p not in sys.path:
        sys.path.insert(0, p)

def test_import(module_name, description):
    """Test importing a module and report results."""
    print(f"\n{'='*60}")
    print(f"Testing: {module_name}")
    print(f"Description: {description}")
    print('='*60)
    
    try:
        if module_name == "cryptography":
            from cryptography.fernet import Fernet
            print(f"SUCCESS: {module_name} imported successfully")
            print(f"   - Fernet available: Yes")
            return True
        else:
            module = __import__(module_name, fromlist=[''])
            print(f"SUCCESS: {module_name} imported successfully")
            return True
    except ImportError as e:
        print(f"IMPORT ERROR: {module_name}")
        print(f"   Error: {e}")
        print(f"   Traceback:")
        traceback.print_exc()
        return False
    except Exception as e:
        print(f"OTHER ERROR: {module_name}")
        print(f"   Error: {e}")
        print(f"   Traceback:")
        traceback.print_exc()
        return False

def test_encrypted_config():
    """Test the encrypted configuration system."""
    print(f"\n{'='*60}")
    print("Testing: Encrypted Configuration System")
    print('='*60)
    
    try:
        from noodlecore.config import get_ai_config, save_ai_config, is_ai_configured
        print("âœ… SUCCESS: Encrypted config functions imported")
        
        # Test getting AI config
        try:
            config = get_ai_config()
            print(f"âœ… SUCCESS: get_ai_config() returned: {config}")
        except Exception as e:
            print(f"ERROR in get_ai_config(): {e}")
            traceback.print_exc()
        
        # Test saving AI config
        try:
            save_ai_config("OpenRouter", "gpt-3.5-turbo", "test-key-123")
            print("âœ… SUCCESS: save_ai_config() completed")
        except Exception as e:
            print(f"ERROR in save_ai_config(): {e}")
            traceback.print_exc()
        
        return True
        
    except Exception as e:
        print(f"ERROR: Failed to import encrypted config: {e}")
        traceback.print_exc()
        return False

def test_role_manager():
    """Test the AI role manager."""
    print(f"\n{'='*60}")
    print("Testing: AI Role Manager")
    print('='*60)
    
    try:
        from noodlecore.ai.role_manager import get_role_manager, AIRole
        print("âœ… SUCCESS: Role manager imported")
        
        # Test getting role manager
        try:
            role_manager = get_role_manager()
            print(f"âœ… SUCCESS: get_role_manager() returned: {type(role_manager)}")
            
            # Test getting roles
            roles = role_manager.get_all_roles()
            print(f"âœ… SUCCESS: Found {len(roles)} roles")
            
        except Exception as e:
            print(f"ERROR in role manager operations: {e}")
            traceback.print_exc()
        
        return True
        
    except Exception as e:
        print(f"ERROR: Failed to import role manager: {e}")
        traceback.print_exc()
        return False

def test_ide_ai_config():
    """Test the IDE AI configuration loading."""
    print(f"\n{'='*60}")
    print("Testing: IDE AI Configuration Loading")
    print('='*60)
    
    try:
        # Test the specific import that happens in native_gui_ide.py
        from noodlecore.config import get_ai_config
        print("âœ… SUCCESS: get_ai_config imported from noodlecore.config")
        
        # Test calling it like the IDE does
        try:
            ai_config = get_ai_config()
            print(f"âœ… SUCCESS: get_ai_config() called successfully")
            print(f"   Provider: {ai_config.get('provider', 'Not set')}")
            print(f"   Model: {ai_config.get('model', 'Not set')}")
            print(f"   Has API Key: {bool(ai_config.get('ai_api_key', ''))}")
            
        except Exception as e:
            print(f"ERROR calling get_ai_config(): {e}")
            traceback.print_exc()
        
        return True
        
    except Exception as e:
        print(f"ERROR: Failed to test IDE AI config: {e}")
        traceback.print_exc()
        return False

def main():
    """Run all diagnostic tests."""
    print("NoodleCore IDE AI Configuration Import Diagnostic")
    print("=" * 60)
    print(f"Python version: {sys.version}")
    print(f"Python path includes:")
    for p in sys.path:
        print(f"  {p}")
    
    # Test basic dependencies
    results = {}
    
    # Test cryptography (critical dependency)
    results['cryptography'] = test_import("cryptography", "AES encryption library for secure config storage")
    
    # Test other optional dependencies
    results['pygments'] = test_import("pygments", "Syntax highlighting library")
    
    # Test NoodleCore modules
    results['noodlecore.config'] = test_import("noodlecore.config", "Encrypted configuration module")
    results['noodlecore.ai.role_manager'] = test_import("noodlecore.ai.role_manager", "AI role management system")
    
    # Test specific functionality
    results['encrypted_config'] = test_encrypted_config()
    results['role_manager'] = test_role_manager()
    results['ide_ai_config'] = test_ide_ai_config()
    
    # Summary
    print(f"\n{'='*60}")
    print("DIAGNOSTIC SUMMARY")
    print('='*60)
    
    success_count = sum(1 for result in results.values() if result)
    total_count = len(results)
    
    for test_name, result in results.items():
        status = "PASS" if result else "FAIL"
        print(f"{status}: {test_name}")
    
    print(f"\nOverall: {success_count}/{total_count} tests passed")
    
    if not results.get('cryptography', False):
        print("\nCRITICAL ISSUE: cryptography library is missing!")
        print("   This is required for encrypted AI configuration storage.")
        print("   Install with: pip install cryptography>=3.4.8")
    
    if not results.get('noodlecore.config', False):
        print("\nCRITICAL ISSUE: noodlecore.config module failed to import!")
        print("   This is required for AI settings loading.")
    
    if not results.get('encrypted_config', False):
        print("\nCRITICAL ISSUE: Encrypted configuration system failed!")
        print("   AI settings cannot be loaded or saved.")
    
    return success_count == total_count

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

