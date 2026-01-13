# 🔒 NoodleCore Encrypted Configuration System

## Overview

This document describes the new encrypted configuration system implemented for NoodleCore IDE to securely store API keys and other sensitive configuration data.

## 🎯 Problem Solved

Previously, users had to re-enter their API keys every time the IDE was updated because:

- API keys were stored in plain text configuration files
- No secure storage mechanism existed
- Configuration was lost during IDE updates
- Manual environment variable setup was required

## 🔧 Solution Implemented

### Core Features

1. **AES-256 Encryption**: All sensitive data is encrypted using industry-standard AES-256 encryption
2. **Machine-Specific Keys**: Encryption keys are derived from machine-specific fingerprint
3. **Automatic Migration**: Seamless migration from legacy plain-text configuration
4. **Secure Storage**: Configuration files with restricted permissions (600 on Unix-like systems)
5. **Backward Compatibility**: Full support for existing configuration methods

### Security Features

- **Machine Fingerprinting**: Uses platform, processor, system, and user information to create unique machine identifiers
- **Key Derivation**: PBKDF2HMAC with SHA-256 for secure key derivation
- **File Permissions**: Restrictive permissions on configuration files
- **Backup Creation**: Automatic backup before configuration changes
- **Validation**: Configuration integrity validation with machine fingerprint verification

## 📁 Files Created

### Core Module Files

```
noodle-core/src/noodlecore/config/
├── __init__.py                    # Module initialization
└── encrypted_config.py            # Main encrypted configuration implementation
```

### Configuration Files

```
~/.noodlecore/ (Linux/macOS) or %APPDATA%/NoodleCore (Windows)
├── .config_key                    # Machine-specific encryption key (restricted permissions)
├── encrypted_config.json          # Encrypted configuration data
├── encrypted_config.json.bak        # Automatic backup
└── encrypted_config.json.legacy_backup  # Legacy config backup
```

## 🚀 Usage

### For Users

1. **First Time Setup**:
   - Enter your API key through AI Settings in the IDE
   - Your key will be automatically encrypted and stored securely
   - No manual configuration required

2. **Subsequent IDE Launches**:
   - Your API key is automatically loaded from encrypted storage
   - No re-entry required unless you want to change providers

3. **Multiple Machines**:
   - Each machine has its own encryption key
   - Configuration is tied to your specific machine
   - Secure transfer not supported (by design for security)

### For Developers

```python
# Using the encrypted configuration system
from noodlecore.config import get_ai_config, save_ai_config, is_ai_configured

# Check if AI is configured
if is_ai_configured():
    print("AI is configured with encrypted API key")
else:
    print("AI not configured - please set up in IDE")

# Get current configuration
ai_config = get_ai_config()
print(f"Provider: {ai_config.get('provider')}")
print(f"Model: {ai_config.get('model')}")

# Save new configuration
save_ai_config(
    provider='OpenAI',
    model='gpt-4',
    api_key='your-api-key-here',
    use_noodle_runtime_for_python=True
)
```

## 🔒 Security Details

### Encryption Process

1. **Key Generation**: Fernet.generate_key() creates a 32-byte random key
2. **Data Encryption**: Fernet cipher encrypts data with the key
3. **Storage**: Encrypted data is base64 encoded and stored in JSON
4. **Machine Binding**: Configuration is tied to machine fingerprint for added security

### Machine Fingerprint Components

- Platform information (Windows/Linux/macOS)
- Processor information
- System node name
- Current user account
- Combined SHA-256 hash

## 🔄 Migration Process

### From Legacy to Encrypted

1. **Detection**: Automatically detects existing plain-text configuration
2. **Migration**: Moves sensitive data to encrypted storage
3. **Backup**: Creates backup of legacy configuration
4. **Cleanup**: Removes sensitive data from legacy files

### Migration Safety

- **Backup Creation**: Legacy files are backed up before migration
- **Validation**: Encrypted configuration is validated after migration
- **Rollback**: Automatic rollback if migration fails

## 🛠️ Installation Requirements

### Dependencies

```bash
pip install cryptography>=3.4.8
```

### Requirements File

A `requirements-encrypted-config.txt` file has been created with the cryptography dependency specification.

## 🔧 Configuration API

### Core Functions

```python
# Get configuration manager instance
from noodlecore.config import get_config_manager
config_manager = get_config_manager()

# Set configuration values
config_manager.set('api_key', 'your-secret-key')
config_manager.set('provider', 'OpenAI')

# Get configuration values
api_key = config_manager.get('api_key', 'default-key')
provider = config_manager.get('provider', 'OpenRouter')

# Delete configuration values
config_manager.delete('api_key')

# Get all configuration
all_config = config_manager.get_all()

# Clear all configuration
config_manager.clear()

# Reset configuration (new machine)
config_manager.reset_config()
```

### AI-Specific Functions

```python
# Get AI configuration
from noodlecore.config import get_ai_config, save_ai_config, is_ai_configured

ai_config = get_ai_config()
# Returns: {'provider': 'OpenRouter', 'model': 'gpt-3.5-turbo', 'api_key': 'sk-...', 'use_noodle_runtime_for_python': False}

# Save AI configuration
save_ai_config(
    provider='OpenAI',
    model='gpt-4',
    api_key='sk-your-key-here',
    use_noodle_runtime_for_python=True
)

# Check if AI is configured
if is_ai_configured():
    print("AI is properly configured")
else:
    print("AI needs to be configured")
```

## 🔍 Troubleshooting

### Common Issues

1. **Import Error**: `ModuleNotFoundError: No module named 'cryptography'`
   - **Solution**: Install with `pip install cryptography>=3.4.8`

2. **Permission Error**: Cannot access configuration files
   - **Solution**: Check file permissions in `.noodlecore` directory

3. **Configuration Not Loading**: Settings not persisting
   - **Solution**: Check if machine fingerprint changed (new machine)

4. **Unicode Issues**: Console encoding errors on Windows
   - **Solution**: Use proper terminal encoding or IDE console

### Debug Mode

Enable debug output by setting environment variable:

```bash
export NOODLE_DEBUG_CONFIG=1
```

## 🎉 Benefits

1. **Security**: API keys are encrypted and protected
2. **Persistence**: Configuration survives IDE updates
3. **Convenience**: One-time setup, automatic loading thereafter
4. **Backward Compatibility**: Existing setups continue to work
5. **Machine Portability**: Configuration works across different machines
6. **No Manual Setup**: Environment variables no longer required

## 🔐 Security Considerations

- **Machine-Specific**: Configuration is tied to individual machines
- **No Cloud Sync**: Configuration is local-only for security
- **Key Recovery**: Lost keys require re-configuration (by design)
- **File Permissions**: Configuration files have restricted access
- **Encryption Standard**: Uses Fernet (AES-256-CBC) from cryptography library

## 📝 Development Notes

### Extending the System

To add new configuration options:

1. Add to `EncryptedConfigManager` class
2. Update `get_ai_config()` and `save_ai_config()` functions
3. Update migration logic if needed
4. Update documentation

### Testing

Run the test suite:

```bash
cd noodle-core
python standalone_config_test.py
```

### Code Style

- Follow PEP 8 guidelines
- Use type hints where appropriate
- Include comprehensive error handling
- Add logging for debugging

---

## 📞 Support

For issues or questions about the encrypted configuration system:

1. Check the troubleshooting section above
2. Run the diagnostic test: `python standalone_config_test.py`
3. Check IDE logs for configuration-related messages
4. Ensure cryptography dependency is installed

**Version**: 1.0  
**Last Updated**: 2025-11-27
