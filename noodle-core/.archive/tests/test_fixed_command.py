#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_fixed_command.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the fixed Python command works correctly in all scenarios
"""

import subprocess
import sys
import os

def test_fixed_command():
    """Test the fixed command from the batch file"""
    print("Testing the fixed command from START_NOODLECORE_IDE.bat...")
    
    # Fixed command from the batch file
    fixed_command = """exec('''try:\n    from noodlecore.config import is_ai_configured\n    if is_ai_configured():\n        print('[OK] AI configuration found in encrypted storage')\n    else:\n        print('[INFO] No AI configuration found - you can set it up in the IDE')\nexcept ImportError:\n    print('[WARNING] Encrypted config not available - using environment variables')\nexcept Exception as e:\n    print('[ERROR] Failed to check AI configuration: ' + str(e))\n''')"""
    
    try:
        result = subprocess.run([
            sys.executable, '-c', fixed_command
        ], capture_output=True, text=True, cwd='src')
        
        print(f"Return code: {result.returncode}")
        print(f"STDOUT: {result.stdout}")
        print(f"STDERR: {result.stderr}")
        
        # Verify no syntax errors
        if result.returncode == 0 and not result.stderr:
            print("âœ“ FIXED: Command executes without syntax errors")
            return True
        else:
            print("âœ— FAILED: Command still has issues")
            return False
            
    except Exception as e:
        print(f"Exception running fixed command: {e}")
        return False

def test_with_mock_config():
    """Test with a mock configuration to verify all code paths"""
    print("\n" + "="*50)
    print("Testing with mock configuration...")
    
    # Create a temporary test script that simulates different scenarios
    test_script = '''
import sys
sys.path.insert(0, "src")

# Mock the is_ai_configured function to test different scenarios
class MockConfig:
    def __init__(self, configured=False):
        self.configured = configured
    
    def is_ai_configured(self):
        return self.configured

# Test scenario 1: AI is configured
print("=== Scenario 1: AI is configured ===")
try:
    # Mock the config module
    import types
    mock_module = types.ModuleType('noodlecore.config')
    mock_module.is_ai_configured = lambda: True
    sys.modules['noodlecore.config'] = mock_module
    
    exec("""try:
    from noodlecore.config import is_ai_configured
    if is_ai_configured():
        print('[OK] AI configuration found in encrypted storage')
    else:
        print('[INFO] No AI configuration found - you can set it up in the IDE')
except ImportError:
    print('[WARNING] Encrypted config not available - using environment variables')
except Exception as e:
    print('[ERROR] Failed to check AI configuration: ' + str(e))
""")
except Exception as e:
    print(f"Error in scenario 1: {e}")

# Test scenario 2: AI is not configured
print("\\n=== Scenario 2: AI is not configured ===")
try:
    mock_module.is_ai_configured = lambda: False
    
    exec("""try:
    from noodlecore.config import is_ai_configured
    if is_ai_configured():
        print('[OK] AI configuration found in encrypted storage')
    else:
        print('[INFO] No AI configuration found - you can set it up in the IDE')
except ImportError:
    print('[WARNING] Encrypted config not available - using environment variables')
except Exception as e:
    print('[ERROR] Failed to check AI configuration: ' + str(e))
""")
except Exception as e:
    print(f"Error in scenario 2: {e}")

# Test scenario 3: ImportError (encrypted config not available)
print("\\n=== Scenario 3: ImportError (encrypted config not available) ===")
try:
    # Remove the mock module to trigger ImportError
    if 'noodlecore.config' in sys.modules:
        del sys.modules['noodlecore.config']
    
    exec("""try:
    from noodlecore.config import is_ai_configured
    if is_ai_configured():
        print('[OK] AI configuration found in encrypted storage')
    else:
        print('[INFO] No AI configuration found - you can set it up in the IDE')
except ImportError:
    print('[WARNING] Encrypted config not available - using environment variables')
except Exception as e:
    print('[ERROR] Failed to check AI configuration: ' + str(e))
""")
except Exception as e:
    print(f"Error in scenario 3: {e}")
'''
    
    try:
        result = subprocess.run([
            sys.executable, '-c', test_script
        ], capture_output=True, text=True, cwd='.')
        
        print(f"Return code: {result.returncode}")
        print(f"STDOUT: {result.stdout}")
        if result.stderr:
            print(f"STDERR: {result.stderr}")
        
        # Check if all scenarios produced expected output
        stdout = result.stdout
        if ('[OK] AI configuration found in encrypted storage' in stdout and
            '[INFO] No AI configuration found - you can set it up in the IDE' in stdout and
            '[WARNING] Encrypted config not available - using environment variables' in stdout):
            print("âœ“ ALL SCENARIOS: All three output messages are working correctly")
            return True
        else:
            print("âœ— SCENARIOS: Some scenarios may not be working correctly")
            return False
            
    except Exception as e:
        print(f"Exception running scenario test: {e}")
        return False

if __name__ == "__main__":
    success1 = test_fixed_command()
    success2 = test_with_mock_config()
    
    print("\n" + "="*50)
    print("FINAL RESULTS:")
    print("="*50)
    
    if success1 and success2:
        print("âœ“ ALL TESTS PASSED: The syntax error has been successfully fixed!")
        print("âœ“ The command now works correctly in all scenarios:")
        print("  - AI configured: Shows '[OK] AI configuration found in encrypted storage'")
        print("  - AI not configured: Shows '[INFO] No AI configuration found - you can set it up in the IDE'")
        print("  - ImportError: Shows '[WARNING] Encrypted config not available - using environment variables'")
    else:
        print("âœ— SOME TESTS FAILED: There may still be issues with the fix")
    
    print("="*50)

