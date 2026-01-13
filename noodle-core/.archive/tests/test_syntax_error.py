#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_error.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Diagnostic script to test the problematic Python one-liner syntax
"""

import subprocess
import sys

def test_current_command():
    """Test the current problematic command"""
    print("Testing current problematic command...")
    
    # Current problematic command from the batch file
    current_command = """try: from noodlecore.config import is_ai_configured; print('[OK] AI configuration found in encrypted storage' if is_ai_configured() else '[INFO] No AI configuration found - you can set it up in the IDE'); except ImportError: print('[WARNING] Encrypted config not available - using environment variables'); except Exception as e: print('[ERROR] Failed to check AI configuration: ' + str(e))"""
    
    try:
        result = subprocess.run([
            sys.executable, '-c', current_command
        ], capture_output=True, text=True, cwd='src')
        
        print(f"Return code: {result.returncode}")
        print(f"STDOUT: {result.stdout}")
        print(f"STDERR: {result.stderr}")
        
        return result.returncode != 0
        
    except Exception as e:
        print(f"Exception running command: {e}")
        return True

def test_alternative_approaches():
    """Test alternative approaches that should work"""
    print("\n" + "="*50)
    print("Testing alternative approaches...")
    
    # Alternative 1: Using exec() with triple quotes
    alternative1 = '''exec("""try:
    from noodlecore.config import is_ai_configured
    if is_ai_configured():
        print('[OK] AI configuration found in encrypted storage')
    else:
        print('[INFO] No AI configuration found - you can set it up in the IDE')
except ImportError:
    print('[WARNING] Encrypted config not available - using environment variables')
except Exception as e:
    print('[ERROR] Failed to check AI configuration: ' + str(e))
""")'''
    
    print("\nTesting Alternative 1 (exec with triple quotes)...")
    try:
        result = subprocess.run([
            sys.executable, '-c', alternative1
        ], capture_output=True, text=True, cwd='src')
        
        print(f"Return code: {result.returncode}")
        print(f"STDOUT: {result.stdout}")
        print(f"STDERR: {result.stderr}")
        
    except Exception as e:
        print(f"Exception running alternative 1: {e}")
    
    # Alternative 2: Using lambda and exception handling
    alternative2 = '''import sys; import os; sys.path.insert(0, os.path.join(os.getcwd(), 'src')); exec("try:\\n from noodlecore.config import is_ai_configured\\n if is_ai_configured():\\n  print('[OK] AI configuration found in encrypted storage')\\n else:\\n  print('[INFO] No AI configuration found - you can set it up in the IDE')\\nexcept ImportError:\\n print('[WARNING] Encrypted config not available - using environment variables')\\nexcept Exception as e:\\n print('[ERROR] Failed to check AI configuration: ' + str(e))")'''
    
    print("\nTesting Alternative 2 (exec with escaped newlines)...")
    try:
        result = subprocess.run([
            sys.executable, '-c', alternative2
        ], capture_output=True, text=True, cwd='.')
        
        print(f"Return code: {result.returncode}")
        print(f"STDOUT: {result.stdout}")
        print(f"STDERR: {result.stderr}")
        
    except Exception as e:
        print(f"Exception running alternative 2: {e}")

if __name__ == "__main__":
    has_error = test_current_command()
    
    if has_error:
        print("\n" + "="*50)
        print("CONFIRMED: Current command has syntax error")
        print("="*50)
    
    test_alternative_approaches()

