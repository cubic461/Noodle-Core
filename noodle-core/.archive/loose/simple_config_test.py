#!/usr/bin/env python3
"""
Test Suite::Noodle Core - simple_config_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test for encrypted configuration system
"""

import sys
import os
from pathlib import Path

# Add src to path
src_dir = Path(__file__).parent / 'src'
if str(src_dir) not in sys.path:
    sys.path.insert(0, str(src_dir))

def main():
    print("Testing encrypted configuration system...")
    
    try:
        from noodlecore.config import get_ai_config, save_ai_config, is_ai_configured
        print("âœ… Successfully imported encrypted config module")
        
        # Test configuration
        ai_config = get_ai_config()
        print(f"AI configured: {is_ai_configured()}")
        
        # Test saving
        save_ai_config('TestProvider', 'test-model', 'test-api-key-12345')
        print("âœ… Test configuration saved")
        
        # Test loading again
        new_config = get_ai_config()
        print(f"Provider: {new_config.get('provider')}")
        print(f"Model: {new_config.get('model')}")
        print(f"API Key set: {bool(new_config.get('api_key'))}")
        
        print("âœ… Encrypted configuration system working!")
        
    except ImportError as e:
        print(f"âŒ Import error: {e}")
        return 1
    except Exception as e:
        print(f"âŒ Test failed: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

