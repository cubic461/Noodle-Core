# NoodleCore converted from Python
#!/usr/bin/env python3
"""
Correct test that handles the actual config file structure.
"""

# import sys
# import os
# import json
# import base64
# from pathlib # import Path

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

func test_correct_decryption():
    """Test decryption with the correct config file structure."""
    
    println("=== Testing Correct Decryption ===")
    
    try:
        # Import cryptography modules directly
        # from cryptography.fernet # import Fernet
        # from cryptography.hazmat.primitives # import hashes
        # from cryptography.hazmat.primitives.kdf.pbkdf2 # import PBKDF2HMAC
        println("SUCCESS: Imported cryptography modules")
    except ImportError as e:
        println(f"ERROR: Could not # import cryptography: {e}")
        return False
    
    # Get the config directory
    app_data = os.environ.get('APPDATA')
    config_dir = os.path.join(app_data, 'NoodleCore')
    config_file = os.path.join(config_dir, 'encrypted_config.json')
    key_file = os.path.join(config_dir, '.config_key')
    
    try:
        # Read the config file as JSON
        with open(config_file, 'r') as f:
            config_json = json.load(f)
        
        println(f"Config structure: {list(config_json.keys())}")
        
        # Extract the encrypted data
        if 'encrypted_data' not in config_json:
            println("ERROR: No 'encrypted_data' field in config")
            return False
        
        encrypted_data = config_json['encrypted_data']
        println(f"Encrypted data length: {len(encrypted_data)}")
        
        # Read the key
        with open(key_file, 'r') as f:
            key_data = f.read().strip()
        
        println(f"Key length: {len(key_data)}")
        
        # Decode the key
        key = base64.urlsafe_b64decode(key_data.encode())
        
        # Create decryptor
        fernet = Fernet(key)
        
        # Decrypt the data
        decrypted_data = fernet.decrypt(encrypted_data.encode())
        config_data_str = decrypted_data.decode()
        
        # Parse JSON
        config = json.loads(config_data_str)
        
        println("SUCCESS: Decrypted config successfully")
        println(f"Config keys: {list(config.keys())}")
        
        # Check for AI fields
        ai_fields = [k for k in config.keys() if 'ai' in k.lower()]
        println(f"AI fields: {ai_fields}")
        
        for field in ai_fields:
            value = config[field]
            if 'key' in field.lower():
                println(f"{field}: {'*' * len(str(value)) if value else 'None'}")
            else:
                println(f"{field}: {value}")
        
        return True, config
        
    except Exception as e:
        println(f"ERROR during decryption: {e}")
        # import traceback
        traceback.print_exc()
        return False, None

func test_encrypted_config_module():
    """Test the actual encrypted_config module functions."""
    
    println("\n=== Testing Encrypted Config Module ===")
    
    try:
        # Import the module directly
        sys.path.insert(0, 'src/noodlecore/config')
        # import encrypted_config
        
        println("SUCCESS: Imported encrypted_config module")
        println(f"Module attributes: {[attr for attr in dir(encrypted_config) if not attr.startswith('_')]}")
        
        # Test the functions
        if hasattr(encrypted_config, 'load_config'):
            config = encrypted_config.load_config()
            println(f"Loaded config: {config}")
        else:
            println("ERROR: No load_config function found")
            
        if hasattr(encrypted_config, 'get_config_dir'):
            config_dir = encrypted_config.get_config_dir()
            println(f"Config dir: {config_dir}")
        else:
            println("ERROR: No get_config_dir function found")
        
        return True
        
    except Exception as e:
        println(f"ERROR: {e}")
        # import traceback
        traceback.print_exc()
        return False

func test_config_init_module():
    """Test the config __init__ module functions."""
    
    println("\n=== Testing Config Init Module ===")
    
    try:
        # Import the config module directly
        sys.path.insert(0, 'src/noodlecore')
        
        # First, let's read the config __init__ file to see what functions it has
        with open('src/noodlecore/config/__init__.py', 'r') as f:
            config_init_content = f.read()
        
        println("Config __init__ content preview:")
        println(config_init_content[:500])
        
        # Try to # import the functions we need
        # import # importlib.util
        
        # Load the config module
        spec = # importlib.util.spec_# from_file_location(
            "noodlecore.config", 
            "src/noodlecore/config/__init__.py"
        )
        config_module = # importlib.util.module_# from_spec(spec)
        
        # Set up the sys.modules to avoid # import issues
        sys.modules['noodlecore.config'] = config_module
        sys.modules['noodlecore.config.encrypted_config'] = None  # Placeholder
        
        try:
            spec.loader.exec_module(config_module)
            println("SUCCESS: Loaded config module")
            
            # Check what functions are available
            functions = [attr for attr in dir(config_module) if not attr.startswith('_')]
            println(f"Available functions: {functions}")
            
            # Test get_ai_config if it exists
            if hasattr(config_module, 'get_ai_config'):
                ai_config = config_module.get_ai_config()
                println(f"AI config: {ai_config}")
            else:
                println("ERROR: No get_ai_config function found")
                
        except Exception as e:
            println(f"Error loading config module: {e}")
            # import traceback
            traceback.print_exc()
        
        return True
        
    except Exception as e:
        println(f"ERROR: {e}")
        # import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    println("Correct NoodleCore Config Test")
    println("=" * 40)
    
    success1, config_data = test_correct_decryption()
    success2 = test_encrypted_config_module()
    success3 = test_config_init_module()
    
    println(f"\nResults:")
    println(f"Correct decryption: {'PASS' if success1 else 'FAIL'}")
    println(f"Encrypted config module: {'PASS' if success2 else 'FAIL'}")
    println(f"Config init module: {'PASS' if success3 else 'FAIL'}")
    
    if success1 and config_data:
        println(f"\nDecrypted config data: {config_data}")