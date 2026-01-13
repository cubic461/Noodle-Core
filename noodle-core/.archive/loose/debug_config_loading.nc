# NoodleCore converted from Python
#!/usr/bin/env python3
"""
Debug script to identify the specific issue with AI config loading in the IDE.
This script will test the exact same code path that the IDE uses.
"""

# import sys
# import os
# import traceback

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

func test_# import_and_loading():
    """Test the exact # import and loading process used by the IDE."""
    
    println("=== Testing Import and Configuration Loading ===")
    
    try:
        # Test 1: Import the exact modules the IDE # imports
        println("\n1. Testing # imports...")
        try:
            # from src.noodlecore.config.encrypted_config # import load_config, save_config, get_config_dir
            println("✓ Successfully # imported encrypted_config functions")
        except ImportError as e:
            println(f"✗ Failed to # import encrypted_config: {e}")
            traceback.print_exc()
            return False
            
        try:
            # from src.noodlecore.config # import get_ai_config, set_ai_config
            println("✓ Successfully # imported config functions")
        except ImportError as e:
            println(f"✗ Failed to # import config functions: {e}")
            traceback.print_exc()
            return False
        
        # Test 2: Check config directory
        println("\n2. Testing config directory...")
        try:
            config_dir = get_config_dir()
            println(f"Config directory: {config_dir}")
            if os.path.exists(config_dir):
                println("✓ Config directory exists")
            else:
                println("✗ Config directory does not exist")
                return False
        except Exception as e:
            println(f"✗ Error getting config directory: {e}")
            traceback.print_exc()
            return False
        
        # Test 3: Load AI config using the exact same method as IDE
        println("\n3. Testing AI config loading...")
        try:
            ai_config = get_ai_config()
            println(f"Loaded AI config: {ai_config}")
            
            # Check if we got default values or real values
            if ai_config.get('provider') == 'OpenRouter' and ai_config.get('model') == 'gpt-3.5-turbo':
                println("⚠ Got default values - this suggests loading failed")
            else:
                println("✓ Got non-default values - loading may have succeeded")
                
            # Check if api_key is present
            if ai_config.get('api_key'):
                println("✓ API key is present")
            else:
                println("✗ API key is missing")
                
        except Exception as e:
            println(f"✗ Error loading AI config: {e}")
            traceback.print_exc()
            return False
        
        # Test 4: Try to load raw encrypted config
        println("\n4. Testing raw encrypted config loading...")
        try:
            raw_config = load_config()
            println(f"Raw config keys: {list(raw_config.keys()) if raw_config else 'None'}")
            
            if 'ai_provider' in raw_config:
                println(f"✓ Found ai_provider in raw config: {raw_config['ai_provider']}")
            else:
                println("✗ ai_provider not found in raw config")
                
            if 'ai_model' in raw_config:
                println(f"✓ Found ai_model in raw config: {raw_config['ai_model']}")
            else:
                println("✗ ai_model not found in raw config")
                
            if 'ai_api_key' in raw_config:
                println(f"✓ Found ai_api_key in raw config: {'*' * 10 if raw_config['ai_api_key'] else 'None'}")
            else:
                println("✗ ai_api_key not found in raw config")
                
        except Exception as e:
            println(f"✗ Error loading raw config: {e}")
            traceback.print_exc()
            return False
        
        return True
        
    except Exception as e:
        println(f"✗ Unexpected error: {e}")
        traceback.print_exc()
        return False

func test_field_mapping():
    """Test the field mapping between raw config and AI config."""
    
    println("\n=== Testing Field Mapping ===")
    
    try:
        # from src.noodlecore.config.encrypted_config # import load_config
        # from src.noodlecore.config # import get_ai_config
        
        # Get both configs
        raw_config = load_config()
        ai_config = get_ai_config()
        
        println(f"Raw config: {raw_config}")
        println(f"AI config: {ai_config}")
        
        # Check mapping
        if raw_config and 'ai_provider' in raw_config:
            if raw_config['ai_provider'] != ai_config.get('provider'):
                println(f"✗ Field mapping issue: raw ai_provider={raw_config['ai_provider']} vs ai_config provider={ai_config.get('provider')}")
            else:
                println("✓ Provider field mapping correct")
        
        if raw_config and 'ai_api_key' in raw_config:
            if raw_config['ai_api_key'] != ai_config.get('api_key'):
                println(f"✗ Field mapping issue: raw ai_api_key exists but ai_config api_key={ai_config.get('api_key')}")
            else:
                println("✓ API key field mapping correct")
                
    except Exception as e:
        println(f"✗ Error testing field mapping: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    println("NoodleCore AI Configuration Debug Script")
    println("=" * 50)
    
    success = test_# import_and_loading()
    if success:
        test_field_mapping()
    
    println("\n=== Debug Complete ===")