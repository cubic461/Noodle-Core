#!/usr/bin/env python3
"""
Noodle Core::Ai Config Fix - ai_config_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
AI Configuration Fix Script

This script fixes the AI configuration loading issue by:
1. Adding missing ai_api_key field to the config file
2. Fixing the model name format
3. Creating a backup of the original config
4. Testing the fix
"""

import json
import shutil
from pathlib import Path

def fix_ai_config():
    """Fix the AI configuration file."""
    config_file = Path.home() / '.noodlecore' / 'ai_config.json'
    
    print("=== AI CONFIGURATION FIX ===")
    print(f"Config file: {config_file}")
    print(f"Config file exists: {config_file.exists()}")
    
    if not config_file.exists():
        print("âŒ Config file does not exist - cannot fix")
        return False
    
    # Read current config
    try:
        with open(config_file, 'r') as f:
            current_config = json.load(f)
        print(f"âœ… Successfully read current config: {current_config}")
    except Exception as e:
        print(f"âŒ Failed to read config: {e}")
        return False
    
    # Create backup
    backup_file = config_file.with_suffix('.json.backup')
    try:
        shutil.copy2(config_file, backup_file)
        print(f"âœ… Created backup: {backup_file}")
    except Exception as e:
        print(f"âŒ Failed to create backup: {e}")
        return False
    
    # Fix the configuration
    fixed_config = current_config.copy()
    
    # 1. Add missing ai_api_key field if it doesn't exist
    if 'ai_api_key' not in fixed_config:
        fixed_config['ai_api_key'] = ''
        print("âœ… Added missing ai_api_key field")
    
    # 2. Fix model name format (remove space)
    if 'model' in fixed_config and fixed_config['model'] == 'glm 4.6':
        fixed_config['model'] = 'glm-4.6'
        print("âœ… Fixed model name format: glm 4.6 â†’ glm-4.6")
    
    # 3. Ensure all required fields exist
    required_fields = ['provider', 'model', 'ai_api_key', 'use_noodle_runtime_for_python']
    for field in required_fields:
        if field not in fixed_config:
            fixed_config[field] = ''
            print(f"âœ… Added missing field: {field}")
    
    # Write fixed config
    try:
        with open(config_file, 'w') as f:
            json.dump(fixed_config, f, indent=2)
        print(f"âœ… Successfully wrote fixed config: {fixed_config}")
    except Exception as e:
        print(f"âŒ Failed to write fixed config: {e}")
        return False
    
    print("\n=== VERIFICATION ===")
    # Verify the fix
    try:
        with open(config_file, 'r') as f:
            verified_config = json.load(f)
        
        print(f"âœ… Verified config: {verified_config}")
        
        # Check if all required fields are present
        missing_fields = [f for f in required_fields if f not in verified_config]
        if missing_fields:
            print(f"âŒ Still missing fields: {missing_fields}")
            return False
        
        if not verified_config.get('ai_api_key'):
            print("âš ï¸ Warning: ai_api_key is empty - user needs to configure API key")
        
        print("âœ… All required fields are present")
        return True
        
    except Exception as e:
        print(f"âŒ Failed to verify config: {e}")
        return False

def test_ide_config_loading():
    """Test if the IDE can now load the configuration properly."""
    print("\n=== IDE CONFIG LOADING TEST ===")
    
    # Simulate the IDE's load_ai_config logic
    config_file = Path.home() / '.noodlecore' / 'ai_config.json'
    
    if not config_file.exists():
        print("âŒ Config file does not exist")
        return False
    
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        # Check if config has the required fields
        provider = config.get('provider', 'OpenRouter')
        model = config.get('model', 'gpt-3.5-turbo')
        api_key = config.get('ai_api_key', '')
        use_noodle_runtime = config.get('use_noodle_runtime_for_python', False)
        
        print(f"âœ… IDE can load config:")
        print(f"   - Provider: {provider}")
        print(f"   - Model: {model}")
        print(f"   - API Key present: {bool(api_key)}")
        print(f"   - Use Noodle Runtime: {use_noodle_runtime}")
        
        if not api_key:
            print("âš ï¸ Note: API key is empty - user needs to configure it in AI Settings")
        
        return True
        
    except Exception as e:
        print(f"âŒ IDE config loading failed: {e}")
        return False

def main():
    """Main function to run the fix."""
    print("NoodleCore IDE AI Configuration Fix")
    print("=" * 40)
    print()
    
    # Fix the configuration
    fix_success = fix_ai_config()
    
    if fix_success:
        # Test IDE loading
        test_success = test_ide_config_loading()
        
        print("\n=== SUMMARY ===")
        if fix_success and test_success:
            print("âœ… AI configuration fix completed successfully!")
            print()
            print("NEXT STEPS:")
            print("1. Restart the NoodleCore IDE")
            print("2. Go to AI menu â†’ AI Settings")
            print("3. Enter your API key for the selected provider")
            print("4. Test the AI chat functionality")
            print()
            print("The AI chat should now work properly!")
        else:
            print("âŒ Fix completed but IDE loading test failed")
    else:
        print("âŒ Failed to fix AI configuration")

if __name__ == "__main__":
    main()

