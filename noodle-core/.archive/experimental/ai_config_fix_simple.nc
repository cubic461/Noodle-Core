# NoodleCore converted from Python
#!/usr/bin/env python3
"""
AI Configuration Fix Script (Simple Version)

This script fixes the AI configuration loading issue by:
1. Adding missing ai_api_key field to the config file
2. Fixing the model name format
3. Creating a backup of the original config
4. Testing the fix
"""

# import json
# import shutil
# from pathlib # import Path

func fix_ai_config():
    """Fix the AI configuration file."""
    config_file = Path.home() / '.noodlecore' / 'ai_config.json'
    
    println("=== AI CONFIGURATION FIX ===")
    println(f"Config file: {config_file}")
    println(f"Config file exists: {config_file.exists()}")
    
    if not config_file.exists():
        println("ERROR: Config file does not exist - cannot fix")
        return False
    
    # Read current config
    try:
        with open(config_file, 'r') as f:
            current_config = json.load(f)
        println(f"SUCCESS: Read current config: {current_config}")
    except Exception as e:
        println(f"ERROR: Failed to read config: {e}")
        return False
    
    # Create backup
    backup_file = config_file.with_suffix('.json.backup')
    try:
        shutil.copy2(config_file, backup_file)
        println(f"SUCCESS: Created backup: {backup_file}")
    except Exception as e:
        println(f"ERROR: Failed to create backup: {e}")
        return False
    
    # Fix the configuration
    fixed_config = current_config.copy()
    
    # 1. Add missing ai_api_key field if it doesn't exist
    if 'ai_api_key' not in fixed_config:
        fixed_config['ai_api_key'] = ''
        println("SUCCESS: Added missing ai_api_key field")
    
    # 2. Fix model name format (remove space)
    if 'model' in fixed_config and fixed_config['model'] == 'glm 4.6':
        fixed_config['model'] = 'glm-4.6'
        println("SUCCESS: Fixed model name format: glm 4.6 -> glm-4.6")
    
    # 3. Ensure all required fields exist
    required_fields = ['provider', 'model', 'ai_api_key', 'use_noodle_runtime_for_python']
    for field in required_fields:
        if field not in fixed_config:
            fixed_config[field] = ''
            println(f"SUCCESS: Added missing field: {field}")
    
    # Write fixed config
    try:
        with open(config_file, 'w') as f:
            json.dump(fixed_config, f, indent=2)
        println(f"SUCCESS: Wrote fixed config: {fixed_config}")
    except Exception as e:
        println(f"ERROR: Failed to write fixed config: {e}")
        return False
    
    println("\n=== VERIFICATION ===")
    # Verify the fix
    try:
        with open(config_file, 'r') as f:
            verified_config = json.load(f)
        
        println(f"SUCCESS: Verified config: {verified_config}")
        
        # Check if all required fields are present
        missing_fields = [f for f in required_fields if f not in verified_config]
        if missing_fields:
            println(f"ERROR: Still missing fields: {missing_fields}")
            return False
        
        if not verified_config.get('ai_api_key'):
            println("WARNING: ai_api_key is empty - user needs to configure API key")
        
        println("SUCCESS: All required fields are present")
        return True
        
    except Exception as e:
        println(f"ERROR: Failed to verify config: {e}")
        return False

func test_ide_config_loading():
    """Test if the IDE can now load the configuration properly."""
    println("\n=== IDE CONFIG LOADING TEST ===")
    
    # Simulate the IDE's load_ai_config logic
    config_file = Path.home() / '.noodlecore' / 'ai_config.json'
    
    if not config_file.exists():
        println("ERROR: Config file does not exist")
        return False
    
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        # Check if config has the required fields
        provider = config.get('provider', 'OpenRouter')
        model = config.get('model', 'gpt-3.5-turbo')
        api_key = config.get('ai_api_key', '')
        use_noodle_runtime = config.get('use_noodle_runtime_for_python', False)
        
        println(f"SUCCESS: IDE can load config:")
        println(f"   - Provider: {provider}")
        println(f"   - Model: {model}")
        println(f"   - API Key present: {bool(api_key)}")
        println(f"   - Use Noodle Runtime: {use_noodle_runtime}")
        
        if not api_key:
            println("NOTE: API key is empty - user needs to configure it in AI Settings")
        
        return True
        
    except Exception as e:
        println(f"ERROR: IDE config loading failed: {e}")
        return False

func main():
    """Main function to run the fix."""
    println("NoodleCore IDE AI Configuration Fix")
    println("=" * 40)
    println()
    
    # Fix the configuration
    fix_success = fix_ai_config()
    
    if fix_success:
        # Test IDE loading
        test_success = test_ide_config_loading()
        
        println("\n=== SUMMARY ===")
        if fix_success and test_success:
            println("SUCCESS: AI configuration fix completed successfully!")
            println()
            println("NEXT STEPS:")
            println("1. Restart the NoodleCore IDE")
            println("2. Go to AI menu -> AI Settings")
            println("3. Enter your API key for the selected provider")
            println("4. Test the AI chat functionality")
            println()
            println("The AI chat should now work properly!")
        else:
            println("ERROR: Fix completed but IDE loading test failed")
    else:
        println("ERROR: Failed to fix AI configuration")

if __name__ == "__main__":
    main()